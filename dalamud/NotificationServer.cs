using Newtonsoft.Json;
using System;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using WebSocketSharp.Server;

namespace DutyDialer
{
    public class NotificationServer
    {
        private const string Endpoint = "/DutyDialer";

        private readonly ServerBehavior behavior;

        private WebSocketServer server;

        private int port;
        public int Port
        {
            get => port; private set => port = value switch
            {
                < IPEndPoint.MinPort or > IPEndPoint.MaxPort
                    => throw new ArgumentOutOfRangeException($"Port must be at least {IPEndPoint.MinPort} and at most {IPEndPoint.MaxPort}."),
                // Using the first free port in case of 0 is conventional
                // and ensures that we know what port is ultimately used.
                // We can't pass 0 to the server anyways, since it throws
                // if the input is less than 1.
                0 => FreeTcpPort(),
                _ => value,
            };
        }

        public bool Active { get; private set; }

        public NotificationServer(int port)
        {
            Port = port;

            this.server = new WebSocketServer(Port);
            this.behavior = new ServerBehavior();
            this.server.AddWebSocketService(Endpoint, () => this.behavior);
        }

        public void NotifyPop(DateTime popTime)
        {
            if (!Active) throw new InvalidOperationException("Server is not active!");

            var ipcMessage = new IpcMessage(IpcMessageType.Pop, new DateTimeOffset(popTime).ToUnixTimeMilliseconds());
            this.behavior.SendMessage(JsonConvert.SerializeObject(ipcMessage));
        }

        public void Start()
        {
            if (Active) return;
            Active = true;
            this.server.Start();
        }

        public void Stop()
        {
            if (!Active) return;
            Active = false;
            this.server.Stop();
        }

        public void RestartWithPort(int newPort)
        {
            Port = newPort;
            Stop();
            this.server = new WebSocketServer(Port);
            this.server.AddWebSocketService(Endpoint, () => this.behavior);
            Start();
        }

        private static int FreeTcpPort()
        {
            var l = new TcpListener(IPAddress.Loopback, 0);
            l.Start();
            var port = ((IPEndPoint)l.LocalEndpoint).Port;
            l.Stop();
            return port;
        }

        private class ServerBehavior : WebSocketBehavior
        {
            public void SendMessage(string message)
            {
                Send(message);
            }

            // Enable re-use of a websocket if the client disconnects
            // https://github.com/sta/websocket-sharp/issues/144
            protected override void OnClose(WebSocketSharp.CloseEventArgs e)
            {
                base.OnClose(e);

                var targetType = typeof(WebSocketBehavior);
                var baseWebsocket = targetType.GetField("_websocket", BindingFlags.Instance | BindingFlags.NonPublic);
                baseWebsocket?.SetValue(this, null);
            }
        }

        [Serializable]
        private class IpcMessage
        {
            [JsonProperty("type")]
            public string Type { get; private set; }

            [JsonProperty("unix_milliseconds")]
            public string UnixMilliseconds { get; private set; }

            public IpcMessage(IpcMessageType type, long unixMilliseconds)
            {
                Type = type.ToString();
                UnixMilliseconds = unixMilliseconds.ToString();
            }
        }

        private enum IpcMessageType
        {
            None,
            Pop,
        }
    }
}
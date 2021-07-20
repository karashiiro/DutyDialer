using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using Dalamud.Plugin;
using ImGuiScene;
using QRCoder;

namespace DutyDialer
{
    public class UrlQrCode : IDisposable
    {
        private readonly PayloadGenerator.Url generator;

        private string tempFilePath;

        public bool IsReady { get; private set; }

#nullable enable
        public TextureWrap? Result { get; private set; }
#nullable disable

        public UrlQrCode(string url)
        {
            this.generator = new PayloadGenerator.Url(url);
        }

        public void GenerateImage(DalamudPluginInterface pluginInterface)
        {
            IsReady = false;
            Result?.Dispose();

            if (File.Exists(this.tempFilePath))
            {
                File.Delete(this.tempFilePath);;
            }

            var payload = this.generator.ToString();
            var qrGenerator = new QRCodeGenerator();
            var qrCodeData = qrGenerator.CreateQrCode(payload, QRCodeGenerator.ECCLevel.Q);
            var qrCode = new QRCode(qrCodeData);
            var bitmap = qrCode.GetGraphic(20);

            // LoadImage seems to be broken when loading from a byte[] (UnauthorizedAccessException on MemoryStream.GetBuffer())
            // so we instead write the image to a temporary file and load it from there.
            this.tempFilePath = Path.GetTempFileName();
            var tempFile = File.Create(tempFilePath);
            bitmap.Save(tempFile, ImageFormat.Png);
            tempFile.Close();

            Result = pluginInterface.UiBuilder.LoadImage(this.tempFilePath);
            IsReady = true;
        }
        
        public void Dispose()
        {
            Result?.Dispose();
        }
    }
}
namespace DutyDialer
{
    internal static class Debug
    {
#if DEBUG
        public const bool InitiallyVisible = true;
#else
        public const bool InitiallyVisible = false;
#endif
    }
}
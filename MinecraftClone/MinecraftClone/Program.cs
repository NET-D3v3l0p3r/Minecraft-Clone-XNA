using System;

namespace MinecraftClone
{
#if WINDOWS || XBOX
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main(string[] args)
        {
            using (MinecraftClone game = new MinecraftClone())
            {
                game.Run();
            }
        }
    }
#endif
}


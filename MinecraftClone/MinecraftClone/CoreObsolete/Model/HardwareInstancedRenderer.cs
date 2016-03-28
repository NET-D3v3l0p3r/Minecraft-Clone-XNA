using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;
using MinecraftClone.Core.Misc;
using MinecraftClone.Core.Camera;
using MinecraftClone.Core.Model;
using System.Threading.Tasks;
using MinecraftClone.CoreII.Models;
using MinecraftClone.CoreII.Chunk;

namespace MinecraftClone.Core.Model
{
    public class HardwareInstancedRenderer
    {
        public GraphicsDevice Device { get; set; }
        public GraphicsDeviceManager Manager { get; set; }

        public Vector2[] Textures;
        public Matrix[] Transformations;

        public List<Vector2> TextureBuffer { get; set; }
        public List<Matrix> MatrixBuffer { get; set; }

        public Matrix WorldMatrix { get; set; }

        private Microsoft.Xna.Framework.Graphics.Model Model;

        private ContentManager ContentManager;
        private DynamicVertexBuffer InstancedVertexBuffer;
        private DynamicVertexBuffer InstancedTextureBuffer;
        private Effect InstancingShader;

        static VertexDeclaration InstancedVertexDeclaration = new VertexDeclaration
        (
          new VertexElement(0, VertexElementFormat.Vector4, VertexElementUsage.BlendWeight, 0),
          new VertexElement(16, VertexElementFormat.Vector4, VertexElementUsage.BlendWeight, 1),
          new VertexElement(32, VertexElementFormat.Vector4, VertexElementUsage.BlendWeight, 2),
          new VertexElement(48, VertexElementFormat.Vector4, VertexElementUsage.BlendWeight, 3)
        );
        static VertexDeclaration InstancedTextureIDs = new VertexDeclaration
        (
            new VertexElement(0, VertexElementFormat.Vector2, VertexElementUsage.TextureCoordinate, 0)
        );

        private Texture2D[] Texture2Ds;

        public HardwareInstancedRenderer(GraphicsDevice device, ContentManager content)
        {
            Device = device;
            ContentManager = content;
            WorldMatrix = Matrix.Identity;
            Model = GlobalModels.IndexModelTuple[0];

            try
            {
                InstancingShader = ContentManager.Load<Effect>("MainShader");
            }
            catch
            {
                Console.WriteLine("An error occured while loading shaders...");
                Environment.Exit(Environment.ExitCode);
            }
            Texture2Ds = new Texture2D[16];

            Textures = new Vector2[0];
            Transformations = new Matrix[0];

            TextureBuffer = new List<Vector2>();
            MatrixBuffer = new List<Matrix>();


        }

        public void BindTexture(Texture2D texture, int index)
        {
            if (index > 15)
                throw new Exception("Maximum index: 16");

            Texture2Ds[index] = texture;
        }

        public void ResizeInstancing(int size)
        {
            Array.Resize(ref Textures, size);
            Array.Resize(ref Transformations, size);
        }

        public void Apply()
        {
            Transformations = MatrixBuffer.ToArray();
            Textures = TextureBuffer.ToArray();
            ChunkManager.PullingShaderData = true;
        }

        public bool Render()
        {
            if (Transformations.Length == 0)
                return false;
            if ((InstancedVertexBuffer == null) || (Transformations.Length > InstancedVertexBuffer.VertexCount))
            {
                if (InstancedVertexBuffer != null)
                {
                    InstancedVertexBuffer.Dispose();
                    InstancedTextureBuffer.Dispose();

                }

                InstancedVertexBuffer = new DynamicVertexBuffer(Device, InstancedVertexDeclaration, Transformations.Length, BufferUsage.WriteOnly);
                InstancedTextureBuffer = new DynamicVertexBuffer(Device, InstancedTextureIDs, Textures.Length, BufferUsage.WriteOnly);
            }

            for (int i = 0; i < Texture2Ds.Length; i++)
            {
                Device.Textures[i] = Texture2Ds[i];
            }

            InstancedVertexBuffer.SetData<Matrix>(Transformations, 0, Transformations.Length, SetDataOptions.Discard);
            InstancedTextureBuffer.SetData<Vector2>(Textures, 0, Textures.Length, SetDataOptions.Discard);

            foreach (var mesh in Model.Meshes)
            {
                foreach (var meshPart in mesh.MeshParts)
                {
                    
                    Device.SetVertexBuffers(
                    new VertexBufferBinding(meshPart.VertexBuffer, 0, 0),
                    new VertexBufferBinding(InstancedVertexBuffer, 0, 1),
                    new VertexBufferBinding(InstancedTextureBuffer, 0, 1));

                    Device.Indices = meshPart.IndexBuffer;

                    InstancingShader.CurrentTechnique = InstancingShader.Techniques["HardwareInstancing"];

                    InstancingShader.Parameters["World"].SetValue(WorldMatrix);
                    InstancingShader.Parameters["View"].SetValue(Camera3D.ViewMatrix);
                    InstancingShader.Parameters["Projection"].SetValue(Camera3D.ProjectionMatrix);
                    InstancingShader.Parameters["EyePosition"].SetValue(Camera3D.CameraPosition);

                    InstancingShader.Parameters["FogEnabled"].SetValue(1.0f);
                    InstancingShader.Parameters["FogColor"].SetValue(Color.CornflowerBlue.ToVector3());
                    InstancingShader.Parameters["FogStart"].SetValue(0.0f);
                    InstancingShader.Parameters["FogEnd"].SetValue(Camera3D.RenderDistance);

                    foreach (EffectPass pass in InstancingShader.CurrentTechnique.Passes)
                    {
                        pass.Apply();
                        Device.DrawInstancedPrimitives(PrimitiveType.TriangleList, 0, 0, 1, 0, 12, Transformations.Length);

                    }

                }
            }




            return true;


        }
    }
}

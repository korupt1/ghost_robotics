float4x4 tW : WORLD <string uiname="Transform";>;

Texture2D tex <string uiname="Texture";>;
Texture2D texUV <string uiname="uv Coordinates Texture";>;

StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
RWStructuredBuffer<float4> rwbuffer : BACKBUFFER;

SamplerState rgbSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

[numthreads(1, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	float4 uvCoords = texUV.SampleLevel(rgbSampler,uv[i.x],0);
	rwbuffer[i.x] = tex.SampleLevel(rgbSampler,uvCoords.xy,0);

}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
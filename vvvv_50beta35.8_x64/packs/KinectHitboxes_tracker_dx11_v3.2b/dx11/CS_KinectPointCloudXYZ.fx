RWStructuredBuffer<float4> PointsRWBuffer : BACKBUFFER;

Texture2D tex <string uiname="Texture";>;
float4x4 tW : WORLD <string uiname="Transform";>;
//Buffer containing uvs for sampling
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;

SamplerState mySampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Clamp;
    AddressV = Clamp;
};

[numthreads(1, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	float4 pointXYZ;
	pointXYZ.z = tan(tex.SampleLevel(mySampler,uv[i.x],0).r*1.5708)*100;
	pointXYZ.x = -(uv[i.x].y-0.5)*pointXYZ.z*0.75;
	pointXYZ.y = (uv[i.x].x-0.5)*pointXYZ.z;
	
	if (pointXYZ.z == 0) {
		pointXYZ.z = 100000; pointXYZ.w = 0; }
		else {
		pointXYZ.w = 1;
	}; 
	
	pointXYZ.xyz = mul(pointXYZ,tW).xyz;
	PointsRWBuffer[i.x] = pointXYZ; 	
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}






  
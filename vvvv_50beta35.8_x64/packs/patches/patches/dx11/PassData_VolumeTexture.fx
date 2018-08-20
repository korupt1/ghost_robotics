

StructuredBuffer<float4> Colors;
StructuredBuffer<float3> force3D;
float Res = 8;

cbuffer cColor : register(b0)
{
	float4x4 Transform <string uiname="Transform"; >;	
}

RWTexture3D<float4> Output : BACKBUFFER;

[numthreads(8, 8, 8)]
void color( uint3 DTid : SV_DispatchThreadID )
{	
	//Calc linear Index for Read Data from linear DataBuffer
	int Index = DTid.x + (DTid.y*Res) + (DTid.z * (Res * Res));	
	//Store Data in 3 Dinemsional Array
	Output[DTid.xyz] = Colors[Index];
}

[numthreads(8, 8, 8)]
void ForceField( uint3 DTid : SV_DispatchThreadID )
{	
	//Calc linear Index for Read Data from linear DataBuffer
	int Index = DTid.x + (DTid.y*Res) + (DTid.z * (Res * Res));	
	//Store Data in 3 Dinemsional Array
	Output[DTid.xyz] = float4(force3D[Index],1);
}
 
technique11 Color
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, color() ) );
	}
}

technique11 Force3D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, ForceField() ) );
	}
}
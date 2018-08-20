#include "particle_struct.fxh"

float4x4 transform;

ByteAddressBuffer RAWMehsData_Buffer;
RWStructuredBuffer<particle> Output : BACKBUFFER;

int strandCount;
int strandLenght;
float lenght;
int MaxCountMehs;
//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	float x = asfloat(RAWMehsData_Buffer.Load((index.x%MaxCountMehs) * 12));
	float y = asfloat(RAWMehsData_Buffer.Load((index.x%MaxCountMehs) * 12 + 4));
	float z = asfloat(RAWMehsData_Buffer.Load((index.x%MaxCountMehs) * 12 + 8));
	
	float3 p = float3(x,y,z);
	p = mul(float4(p,1), transform).xyz;
	if (index.x%strandLenght == 0 && strandCount> 1 )
		Output[index.x].pos = p;

	int id = index.x ;
	float3 currPos = Output[id].pos;
	float3 lastPos = Output[id-1].pos;
	float3 dir = normalize(currPos - lastPos);
	float3 tmpPos;
	
	Output[id].tmpPos = ((lastPos + dir * lenght) + Output[id].acc);
}

technique10 Constant
{
	pass P0s
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}





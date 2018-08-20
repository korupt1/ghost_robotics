//define particle properties
#include "particle_struct.fxh"

float force;
float3 attPos;
float size;
int pCount;
StructuredBuffer<float4> AttractorPosition;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	float3 d = attPos -Output[index.x].pos;
	float dist = length(d);
	d = normalize(d);
	dist = max(dist, 8);
	if (dist < 2)
		dist =9;
	
	
	float strength = (0.4 * force * Output[index.x].mass) / (dist * dist);
	d *= strength;
	
	d /= Output[index.x].mass;
	Output[index.x].acc += d;  
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}





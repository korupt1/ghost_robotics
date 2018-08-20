//define particle properties
#include "particle_struct.fxh"

float force;
float3 attPos;
float size;
StructuredBuffer<float4> AttractorPosition;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	// calc force direction vector
	float3 dir = attPos -Output[index.x].pos;
	// compute force power depending on a ratio between distance and attractor size
	float f = length(dir) / size;
	// check if the calculated distance is bigger than attractor size
	f = 1-f;
	//cut below 0 and above 1
	f = saturate (f);
	// compute some magic
	f = pow (f, 2.71);
	// apply force in the direction of attractors position
	Output[index.x].acc += dir * f * force;
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}





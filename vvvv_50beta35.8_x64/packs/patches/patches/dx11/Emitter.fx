//define particle properties
#include "particle_struct.fxh"

int indexOffset;
int emitCount;
int particleCount;
bool emit;

// emitter position
StructuredBuffer<float3> EmitterPos;
// emitter acceleration
StructuredBuffer<float3> Acceleration;
// emitter mass
StructuredBuffer<float> Mass;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(1, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	if (emit)
	{
	//Calc Data Position in Buffer from Thread-Index 
	uint emitIndex = index.x% emitCount;
	//Load Emit Pos from Buffer
	float3 p = EmitterPos[emitIndex];
	//Load Emit Acceleration from Buffer
	float3 a = Acceleration[emitIndex] * 0.1;
	
	//calc index offset
	uint bufferIndex = indexOffset + index.x;
	//Dont rise over ParticleCount
	bufferIndex %= particleCount;
	
	//Save Emit Data to RWBuffer
	Output[bufferIndex].mass = Mass[emitIndex];
	Output[bufferIndex].acc = a;
	Output[bufferIndex].vel = float3(0,0,0);
	Output[bufferIndex].pos = p;
	Output[bufferIndex].age = 0;
	}
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}





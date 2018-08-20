//define particle properties
#include "particle_struct.fxh"

int MaxCountMehs;
int indexOffset;
int emitCount;
int particleCount;
bool emit;
float4x4 transform;

ByteAddressBuffer RAWMehsData_Buffer;
//StructuredBuffer<float3> EmitterPos;
StructuredBuffer<float3> Acceleration;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//mass buffer
StructuredBuffer<float> Mass;

//get random indices for emission
StructuredBuffer<uint> rnd;

// random pointer to rndIndex;
int shiftIndex;



//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(1, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	if (emit)
	{
		//calc random index
		//uint rndIndex = index.x + shiftIndex;
		//rndIndex = rndIndex % emitCount;
		
		//generate index to pick indices from random buffer
		uint rndIndex = index.x + shiftIndex;
		
		//pick indices from random buffer
		rndIndex = rnd[rndIndex];

	float x = asfloat(RAWMehsData_Buffer.Load((rndIndex%MaxCountMehs) * 12));
	float y = asfloat(RAWMehsData_Buffer.Load((rndIndex%MaxCountMehs) * 12 + 4));
	float z = asfloat(RAWMehsData_Buffer.Load((rndIndex%MaxCountMehs) * 12 + 8));
		
		
	// get initial position from Emitter
	uint emitIndex = index.x % emitCount;

	float3 p = float3(x,y,z);
	p = mul(float4(p, 1), transform).xyz;
		
	float3 a = Acceleration[emitIndex]/100;
	
	//calc index offset
	uint bufferIndex = (indexOffset + index.x) % particleCount;
	
	Output[bufferIndex].pos = p;
	Output[bufferIndex].acc = a;
	Output[bufferIndex].mass = Mass[emitIndex];
	Output[bufferIndex].age = 0;
	Output[bufferIndex].vel = float3(0,0,0);
	}

}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}





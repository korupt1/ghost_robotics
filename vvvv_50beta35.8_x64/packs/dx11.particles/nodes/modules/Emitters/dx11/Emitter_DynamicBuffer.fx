#include <packs\dx11.particles\nodes\modules\Core\fxh\Core.fxh>

struct Particle {
	#if defined(COMPOSITESTRUCT)
  		COMPOSITESTRUCT
 	#else
		float3 position;
		float3 velocity;
		float3 force;
		float lifespan;
		float age;
	#endif
};

RWStructuredBuffer<Particle> ParticleBuffer : PARTICLEBUFFER;
RWStructuredBuffer<uint> EmitterCounterBuffer : EMITTERCOUNTERBUFFER;
RWStructuredBuffer<uint> AlivePointerBuffer : ALIVEPOINTERBUFFER;
RWStructuredBuffer<uint> AliveCounterBuffer : ALIVECOUNTERBUFFER;

StructuredBuffer<float3> PositionBuffer <string uiname="Position Buffer";>;
StructuredBuffer<float3> VelocityBuffer <string uiname="Velocity Buffer";>;
StructuredBuffer<float3> ForceBuffer <string uiname="Force Buffer";>;
StructuredBuffer<float> LifespanBuffer <string uiname="Lifespan Buffer";>;

cbuffer cbuf
{
    uint EmitCount = 0;
	uint EmitterSize = 0;
	bool ForceEmission = false;
	uint OffsetEmission = 0;
	float4 color <bool color=true;String uiname="Default Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float3 scale <String uiname="Default Scale";> = { 1.0f,1.0f,1.0f };
}

struct csin
{
	uint3 DTID : SV_DispatchThreadID;
	uint3 GTID : SV_GroupThreadID;
	uint3 GID : SV_GroupID;
};

[numthreads(XTHREADS, YTHREADS, ZTHREADS)]
void CS_Emit(csin input)
{
	
	if(input.DTID.x >= EmitterSize) return;
	
	uint particleIndex = EMITTEROFFSET + input.DTID.x;
	
	float currentLifespan = ParticleBuffer[particleIndex].lifespan;
	if ( currentLifespan <= 0.0f || ForceEmission){
		
		// this counter is just for checking if we already emitted enough particles
		uint emitterCounter = EmitterCounterBuffer.IncrementCounter(); 
		if (emitterCounter >= EmitCount )return;
		
		if (ForceEmission) particleIndex = EMITTEROFFSET + ((emitterCounter + OffsetEmission) % EmitterSize) ;
		
		// update AlivePointerBuffer
		uint aliveIndex = AliveCounterBuffer[0] + AliveCounterBuffer.IncrementCounter();
		AlivePointerBuffer[aliveIndex] = particleIndex;
		
		// create new particle
		
		Particle p = (Particle) 0;
		uint size, stride;
		PositionBuffer.GetDimensions(size,stride);
		p.position = PositionBuffer[emitterCounter % size];
		
		VelocityBuffer.GetDimensions(size,stride);
		p.velocity = VelocityBuffer[emitterCounter % size];
		
		ForceBuffer.GetDimensions(size,stride);
		p.force = ForceBuffer[emitterCounter % size];

		LifespanBuffer.GetDimensions(size,stride);
		p.lifespan = LifespanBuffer[emitterCounter % size];
		
		#if defined(KNOW_SCALE)
            p.scale = scale;
    	#endif
		#if defined(KNOW_COLOR)
            p.color = color;
    	#endif
		
		ParticleBuffer[particleIndex] = p;
		
	}
}

technique11 EmitParticles { pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Emit() ) );} }
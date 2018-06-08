#include <packs\dx11.particles\nodes\modules\Core\fxh\Core.fxh>

Texture2D texPeak;
SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};

struct Particle {
	#if defined(COMPOSITESTRUCT)
  		COMPOSITESTRUCT
 	#else
		float3 position;
	#endif
};
StructuredBuffer<Particle> ParticleBuffer;
StructuredBuffer<uint> AlivePointerBuffer;
StructuredBuffer<uint> AliveCounterBuffer;

RWStructuredBuffer<float4> PeakBuffer : BACKBUFFER;
int mode = 0;

struct csin
{
	uint3 DTID : SV_DispatchThreadID;
	uint3 GTID : SV_GroupThreadID;
	uint3 GID : SV_GroupID;
};

[numthreads(1, 1, 1)]
void CS_Clear(csin input)
{
	PeakBuffer[input.DTID.x] = float4(0,0,0,0);
}

[numthreads(XTHREADS, YTHREADS, ZTHREADS)]
void CS_Peak(csin input)
{
	if(input.DTID.x >= MAXPARTICLECOUNT || input.DTID.x >= AliveCounterBuffer[0]) return;
	uint particleIndex = AlivePointerBuffer[input.DTID.x];
	
	float3 position = ParticleBuffer[particleIndex].position;
	
	for (int j = 0; j < MAXGROUPCOUNT;  j++){
		
		float pixPos = ((1.0f / MAXGROUPCOUNT) * j) ;
		float halfPixel = (1.0f / MAXGROUPCOUNT) * 0.5f;
		pixPos += halfPixel;
		float4 peakCoord = texPeak.SampleLevel(sPoint, float2(pixPos,0),0);
	
		if (
			((mode == 0 || mode == 2) && position.x == peakCoord.x) ||
			((mode == 1 || mode == 3) && position.y == peakCoord.y)
		){
			PeakBuffer[j] = float4(ParticleBuffer[particleIndex].position, peakCoord.w);
		}
		//else PeakBuffer[j] = float4(0,0,0,0); 
		
	}	
}

technique11 Clear { pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Clear() ) );} }
technique11 Peak { pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Peak() ) );} }

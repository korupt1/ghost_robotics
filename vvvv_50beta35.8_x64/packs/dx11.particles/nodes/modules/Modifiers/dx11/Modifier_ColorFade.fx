#include <packs\dx11.particles\nodes\modules\Core\fxh\Core.fxh>
#include <packs\dx11.particles\nodes\modules\Core\fxh\IndexFunctions_Particles.fxh>
#include <packs\dx11.particles\nodes\modules\Core\fxh\IndexFunctions_DynBuffer.fxh>

struct Particle {
	#if defined(COMPOSITESTRUCT)
  		COMPOSITESTRUCT
 	#else
		float4 color;
		float age;
		float lifespan;
	#endif
};

RWStructuredBuffer<Particle> ParticleBuffer : PARTICLEBUFFER;

StructuredBuffer<float4> Color0Buffer <string uiname="Color0 Buffer";>;
StructuredBuffer<float4> Color1Buffer <string uiname="Color1 Buffer";>;
StructuredBuffer<float4> Color2Buffer <string uiname="Color3 Buffer";>;
StructuredBuffer<float> FadeInEndBuffer <string uiname="FadeInEnd Buffer";>;
StructuredBuffer<float> FadeOutStartBuffer <string uiname="FadeOutStart Buffer";>;

struct csin
{
	uint3 DTID : SV_DispatchThreadID;
	uint3 GTID : SV_GroupThreadID;
	uint3 GID : SV_GroupID;
};

[numthreads(XTHREADS, YTHREADS, ZTHREADS)]
void CSSet(csin input)
{
	uint particleIndex = GetParticleIndex( input.DTID.x );
	if (particleIndex == -1 ) return;
	
	uint size, stride;
	Color0Buffer.GetDimensions(size,stride);
	float4 color0 = Color0Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color1Buffer.GetDimensions(size,stride);
	float4 color1 = Color1Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color2Buffer.GetDimensions(size,stride);
	float4 color2 = Color2Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeInEndBuffer.GetDimensions(size,stride);
	float fadeInEnd = FadeInEndBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeOutStartBuffer.GetDimensions(size,stride);
	float fadeOutStart = FadeOutStartBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	
	float phase = ParticleBuffer[particleIndex].age / (ParticleBuffer[particleIndex].age + ParticleBuffer[particleIndex].lifespan);
	float mul0 = 1-smoothstep(0, fadeInEnd, phase);
	float mul1 = smoothstep(0, fadeInEnd, phase)* 1 - smoothstep(fadeOutStart, 1, phase);
	float mul2 = smoothstep(fadeOutStart, 1, phase);	
	ParticleBuffer[particleIndex].color = color0 * mul0 + color1 * mul1 + color2 * mul2;
}

[numthreads(XTHREADS, YTHREADS, ZTHREADS)]
void CSAdd(csin input)
{
	uint particleIndex = GetParticleIndex( input.DTID.x );
	if (particleIndex == -1 ) return;
	
	uint size, stride;
	Color0Buffer.GetDimensions(size,stride);
	float4 color0 = Color0Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color1Buffer.GetDimensions(size,stride);
	float4 color1 = Color1Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color2Buffer.GetDimensions(size,stride);
	float4 color2 = Color2Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeInEndBuffer.GetDimensions(size,stride);
	float fadeInEnd = FadeInEndBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeOutStartBuffer.GetDimensions(size,stride);
	float fadeOutStart = FadeOutStartBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	
	float phase = ParticleBuffer[particleIndex].age / (ParticleBuffer[particleIndex].age + ParticleBuffer[particleIndex].lifespan);
	float mul0 = 1-smoothstep(0, fadeInEnd, phase);
	float mul1 = smoothstep(0, fadeInEnd, phase)* 1 - smoothstep(fadeOutStart, 1, phase);
	float mul2 = smoothstep(fadeOutStart, 1, phase);	
	ParticleBuffer[particleIndex].color += color0 * mul0 + color1 * mul1 + color2 * mul2;
}

[numthreads(XTHREADS, YTHREADS, ZTHREADS)]
void CSSubtract(csin input)
{
	uint particleIndex = GetParticleIndex( input.DTID.x );
	if (particleIndex == -1 ) return;
	
	uint size, stride;
	Color0Buffer.GetDimensions(size,stride);
	float4 color0 = Color0Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color1Buffer.GetDimensions(size,stride);
	float4 color1 = Color1Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color2Buffer.GetDimensions(size,stride);
	float4 color2 = Color2Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeInEndBuffer.GetDimensions(size,stride);
	float fadeInEnd = FadeInEndBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeOutStartBuffer.GetDimensions(size,stride);
	float fadeOutStart = FadeOutStartBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	
	float phase = ParticleBuffer[particleIndex].age / (ParticleBuffer[particleIndex].age + ParticleBuffer[particleIndex].lifespan);
	float mul0 = 1-smoothstep(0, fadeInEnd, phase);
	float mul1 = smoothstep(0, fadeInEnd, phase)* 1 - smoothstep(fadeOutStart, 1, phase);
	float mul2 = smoothstep(fadeOutStart, 1, phase);	
	ParticleBuffer[particleIndex].color -= color0 * mul0 + color1 * mul1 + color2 * mul2;
}

[numthreads(XTHREADS, YTHREADS, ZTHREADS)]
void CSMul(csin input)
{
	uint particleIndex = GetParticleIndex( input.DTID.x );
	if (particleIndex == -1 ) return;
	
	uint size, stride;
	Color0Buffer.GetDimensions(size,stride);
	float4 color0 = Color0Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color1Buffer.GetDimensions(size,stride);
	float4 color1 = Color1Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	Color2Buffer.GetDimensions(size,stride);
	float4 color2 = Color2Buffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeInEndBuffer.GetDimensions(size,stride);
	float fadeInEnd = FadeInEndBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	FadeOutStartBuffer.GetDimensions(size,stride);
	float fadeOutStart = FadeOutStartBuffer[GetDynamicBufferIndex( particleIndex, input.DTID.x , size)];
	
	float phase = ParticleBuffer[particleIndex].age / (ParticleBuffer[particleIndex].age + ParticleBuffer[particleIndex].lifespan);
	float mul0 = 1-smoothstep(0, fadeInEnd, phase);
	float mul1 = smoothstep(0, fadeInEnd, phase)* 1 - smoothstep(fadeOutStart, 1, phase);
	float mul2 = smoothstep(fadeOutStart, 1, phase);	
	ParticleBuffer[particleIndex].color *= color0 * mul0 + color1 * mul1 + color2 * mul2;
}

technique11 Set { pass P0{SetComputeShader( CompileShader( cs_5_0, CSSet() ) );} }
technique11 Add { pass P0{SetComputeShader( CompileShader( cs_5_0, CSAdd() ) );} }
technique11 Subtract { pass P0{SetComputeShader( CompileShader( cs_5_0, CSMul() ) );} }
technique11 Mul { pass P0{SetComputeShader( CompileShader( cs_5_0, CSMul() ) );} }
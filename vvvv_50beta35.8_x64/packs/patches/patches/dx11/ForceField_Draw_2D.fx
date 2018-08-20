//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

float4x4 tV : VIEW;
float4x4 tVP : VIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
Texture2D ForceField_Texture; 
Texture2D texture2d;

float4 c <bool color=true;> = 1;
float Scale_ForceField = 1;

StructuredBuffer<float3> WorldPos;
StructuredBuffer<float2> TexCoords;
 
    float3 g_positions[4]:IMMUTABLE =
    {
        float3( -1, 1, 0 ),
        float3( 1, 1, 0 ),
        float3( -1, -1, 0 ),
        float3( 1, -1, 0 ),
    };
    float2 g_texcoords[4]:IMMUTABLE = 
    { 
        float2(0,1), 
        float2(1,1),
        float2(0,0),
        float2(1,0),
    };



SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VS_IN
{
	uint iv : SV_VertexID;	
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION ;	
	float2 TexCd : TEXCOORD0 ;
	float4 Force : TEXCOORD1 ;
	uint iv2 : PrimitiveID;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	
	float4 Force = ForceField_Texture.SampleLevel(g_samLinear, TexCoords[input.iv], 0);
	
    Out.PosWVP = float4(WorldPos[input.iv],1);// mul(float4(po.xyz,1),tVP);
	
	Out.Force = Force;
	Out.iv2 = input.iv;
	
    return Out;
}

[maxvertexcount(2)]
void GS(line vs2ps input[2], inout LineStream<vs2ps> SpriteStream)
{
    vs2ps output;
 
	int i = 0;
    
	float3 position = input[i].PosWVP.xyz;
    output.PosWVP = mul( float4(position,1), tVP );      
    output.TexCd = g_texcoords[i];	
   	output.iv2 = input[i].iv2;
	output.Force = float4(1,1,1,1); 
	SpriteStream.Append(output);
	
	i = 1;
	
	position += input[i].Force.xyz * Scale_ForceField;
    output.PosWVP = mul( float4(position,1), tVP );      
    output.TexCd = g_texcoords[i];	
   	output.iv2 = input[i].iv2;
	output.Force = float4(1,1,1,1);  	    	
    SpriteStream.Append(output);
	
    SpriteStream.RestartStrip();
}

//input[i].Force.xyz

float4 PS_Tex(vs2ps In): SV_Target
{
   float4 col = texture2d.Sample( g_samLinear, In.TexCd)*c;
    return col;
}

technique10 Constant
{
	pass P0
	{
		
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}





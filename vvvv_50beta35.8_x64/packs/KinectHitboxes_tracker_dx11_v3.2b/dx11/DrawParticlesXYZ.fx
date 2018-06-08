//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: vux, mod by id144

float4x4 tV : VIEW;
float4x4 tVP : VIEWPROJECTION;
float4x4 tVI : VIEWINVERSE;
Texture2D texture2d;

float4 c <bool color=true;> = 1;

StructuredBuffer<float4> pData;
StructuredBuffer<float4> RGBPoints;
float radius = 0.05f;
 
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
	//float4 p: POSITION;	
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION ;	
	float4 Col: COLOR ;
	float2 TexCd : TEXCOORD0 ;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	
	float4 p = pData[input.iv];
	Out.Col = RGBPoints[input.iv];
	if (p.w > 0) {
		Out.Col.rb =Out.Col.rb + 0.4;
	} 
    
		
	
	Out.PosWVP = p;// mul(float4(po.xyz,1),tVP);

    return Out;
}

[maxvertexcount(4)]
void GS(point vs2ps input[1], inout TriangleStream<vs2ps> SpriteStream)
{
    vs2ps output;
    
    //
    // Emit two new triangles
    //
    for(int i=0; i<4; i++)
    {
        float3 position = g_positions[i]*(radius+radius*input[0].PosWVP.w*0.4);
        position = mul( position, (float3x3)tVI ) + input[0].PosWVP.xyz;
    	float3 norm = mul(float3(0,0,-1),(float3x3)tVI );
    	output.PosWVP = mul( float4(position,1.0), tVP );
        output.Col = input[0].Col;
        output.TexCd = g_texcoords[i];	

        SpriteStream.Append(output);
    }
    SpriteStream.RestartStrip();
}


float4 PS_Tex(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd);
	col.rgba = In.Col*col;
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




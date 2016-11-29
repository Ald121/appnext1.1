<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Http\Requests;
// Modelos
use App\empresas;
use App\localidades;
// Extras
use Storage;
use File;
use DB;

class busquedaEmpresas extends Controller
{
    public function __construct(){
    	// Modelos
    	$this->empresas=new empresas();
        $this->localidades=new localidades();
        // ------- paths --------------------
        $this->pathImg  = config('global.pathimgPerfiles');
        $this->pathImgPortada  = config('global.pathimgPortadas');
        $this->pathLocal  = Storage::disk('local')->getDriver()->getAdapter()->getPathPrefix();
        // cnoexion-------------
    }
    public function Buscar_Empresas(Request $request){

    if ($request->input('filter')!=null) {
         $datos = DB::connection('infoconex')->select("SELECT id, ruc, razon_social, nombre_comercial, estado_contribuyente, 
       tipo_contribuyente, actividad_economica FROM empresas WHERE (ruc||razon_social||nombre_comercial) like '%".strtoupper($request->input('filter'))."%' LIMIT 5");
    }else{
    	$datos = DB::connection('infoconex')->select("SELECT id, ruc, razon_social, nombre_comercial, estado_contribuyente, 
       tipo_contribuyente, actividad_economica FROM empresas ORDER BY id LIMIT 5");
    }

    foreach ($datos as $key => $value) {
        if ($value->tipo_contribuyente=='OTROS'||$value->tipo_contribuyente=='PERSONAS NATURALES') {
            $value->nombre_comercial=$value->razon_social;
        $img['perfil']=config('global.appnext').config('global.pathAvartarDefault');
        }else{
        $img['perfil']=config('global.appnext').config('global.pathAvartarEmpresasDefault');
        }
        $value->img=$img;
    }

    return response()->json(['respuesta'=>$datos],200);
    }

    public function Get_Perfil_Empresas(Request $request)
    {
        $perfil=str_replace('_', ' ', $request->input('perfil'));

        $datos =  DB::connection('infoconex')->select("SELECT * FROM empresas where razon_social='".$perfil."'");
        $empresa=[];

    foreach ($datos as $key => $value) {

        $datos_ubi=$this->localidades->where('id',$value->descripcion_provincia)->first();
        $value->provincia=$datos_ubi->nombre;
        $datos_ubi=$this->localidades->where('id',$value->descripcion_canton)->first();
        $value->canton=$datos_ubi->nombre;
        $datos_ubi=$this->localidades->where('id',$value->descripcion_parroquia)->first();
        $value->parroquia=$datos_ubi->nombre;

        if ($value->nombre_comercial=='no disponible') {
            $value->nombre_comercial=$value->razon_social;
        }
        if ($value->tipo_contribuyente=='OTROS'||$value->tipo_contribuyente=='PERSONAS NATURALES') {
            $value->nombre_comercial=$value->razon_social;
        $img['perfil']=config('global.appnext').config('global.pathAvartarDefault');
        }else{
        $img['perfil']=config('global.appnext').config('global.pathAvartarEmpresasDefault');
        }
        $img['portada']=config('global.appnext').config('global.pathPortadaDefault');
        $img['logo']=config('global.appnext').config('global.pathLogoDefault');
        $value->img=$img;
    }
    if (count($datos)!=0) {
       return response()->json(['respuesta' => $datos[0]], 200);
    }else{
        return response()->json(['respuesta' => $datos], 200);
    }
    
    }
}

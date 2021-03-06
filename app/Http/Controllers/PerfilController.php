<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Funciones
use App\libs\Funciones;
// Extras
use Carbon\Carbon;
use DB;
use Config;
use Storage;


class PerfilController extends Controller
{

	public function __construct()
    {
        /*$this->middleware('jwt.auth', ['except' => ['authenticate']]);
        //----------------------------------------------- Modelos --------------
        $this->tabla_img=new img_perfiles();
        // --------------------------------------- Autenticacion --------------------
        $this->user = JWTAuth::parseToken()->authenticate();*/
        //----------------------------------- Funciones -------------------------------
        $this->funciones=new Funciones();
        //------------------------------------ Paths -------------------------------
        $this->pathImg  = config('global.pathimgPerfiles');
        $this->pathLocal  = Storage::disk('local')->getDriver()->getAdapter()->getPathPrefix();
    }

    public function Add_Img_Perfil(Request $request){
    
	$id_img=$this->funciones->generarID();

	if (!is_dir($this->pathLocal.$this->user['id_user'])) {
       $path = $this->pathLocal.$this->user['id_user'];
        File::makeDirectory($path);    
    }
    if (!is_dir($this->pathLocal.$this->user['id_user'].$this->pathImg)) {
        $path = $this->pathLocal.$this->user['id_user'].$this->pathImg;
        File::makeDirectory($path); 
    }

	$base64_string = base64_decode($request->input('img'));
	$image_name= $id_img.'.png';
	$path = $this->pathLocal.$this->user['id_user'].$this->pathImg.$image_name;
 	$ifp = fopen($path, "wb"); 
    $data = explode(',', $base64_string);
    fwrite($ifp, base64_decode($data[1])); 
    fclose($ifp);
    $this->tabla_img->where('id_empresa','=',$this->user['id_user'])->update(['estado'=>0]);
    $this->tabla_img->id_img_perfil=$id_img;
    $this->tabla_img->img="storage/app/".$this->user['id_user'].$this->pathImg.$image_name;
    $this->tabla_img->estado='A';
    $this->tabla_img->estado_delete=FALSE;
    $this->tabla_img->id_empresa=$this->user['id_user'];
    $save=$this->tabla_img->save();

    if ($save) {
    return response()->json(["img"=>$image_name]);
    }
    
    }

    public function Set_Img_Perfil(Request $request){
    
    $img=explode('/',$request->input('img'));
    $img=explode('.', $img[count($img)-1]);
    $idimg=$img[0];

	$id_img=$this->funciones->generarID();

    $this->tabla_img->where('id_empresa','=',$this->user['id_user'])->update(['estado'=>0]);
    $resultado=$this->tabla_img->where('id_img_perfil','=',$idimg)->update(['estado'=>1]);
    if ($resultado) {
    $resultado=$this->tabla_img->select('img')->where('estado','=',1)->where('id_empresa','=',$this->user['id_user'])->first();
    return response()->json(["img"=>$resultado['img']]);
    }
    
    }

    public function load_imgs_perfil(Request $request){

    $resultado=$this->tabla_img->select('img','id_img_perfil')->where('id_empresa','=',$this->user['id_user'])->where('estado','=',0)->where('estado_delete',FALSE)->orderBy('created_at','ASC')->get();
    return response()->json(["imgs"=>$resultado]);
    }

    public function Get_Img_Perfil(Request $request){
    
    /*$resultado=$this->tabla_img->select('img','id_img_perfil')->where('estado','=',1)->where('id_empresa','=',$this->user['id_user'])->first();
    // echo($this->pathLocal.$this->user['id_user'].$this->pathImg.$resultado['id_img_perfil'].'.png');
    if (File::exists($this->pathLocal.$this->user['id_user'].$this->pathImg.$resultado['id_img_perfil'].'.png')) {
        return response()->json(['existe'=>true,"img"=>config('global.appnext').'/'.$resultado['img']]);
    }else{*/
        return response()->json(['existe'=>false,"img"=>config('global.appnext').config('global.pathAvartarDefault')]);
    //}
    }

    public function Delete_Img_Perfil(Request $request){
        foreach ($request->input('imgs') as $key => $value) {
            $this->tabla_img->where('id_img_perfil','=',$value['id_img_perfil'])->update(['estado_delete'=>TRUE]);
        }
        return response()->json(['respuesta'=>true]); 
    }
}

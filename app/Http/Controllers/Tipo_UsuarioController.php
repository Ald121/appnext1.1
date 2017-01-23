<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
use \Firebase\JWT\JWT;
use Config;
// Funciones
use App\libs\Funciones;

class Tipo_UsuarioController extends Controller
{
    public function __construct(Request $request){
        // Funciones
        $this->funciones=new Funciones();
        //Autenticacion
        $key=config('jwt.secret');
        $decoded = JWT::decode($request->token, $key, array('HS256'));
        $this->user=$decoded;
        $this->name_bdd=$this->user->nbdb;
    }
    
    public function Existencia_Tipo_Usuario(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->where('estado','A')->where('nombre',$request->nombre)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }


   public function Add_Tipo_Usuario(Request $request)
    {
    
    DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->insert(
        [
         'nombre' => $request->nombre ,
         'descripcion' => $request->descripcion ,
         'estado' => 'A'
         ]);
   // return response()->json(['respuesta' => true], 200);
    $id_tipo_usuario=DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->select('id')->where('estado','A')->where('nombre',$request->nombre)->first();
    $array=$request->input('vistas');
    //NIVEL 0
    foreach($array as $key => $value)
    {
        //return response()->json(['respuesta' => $value['children']], 200);
    // NIVEL 1
    foreach($value['children'] as $key => $value)
        {
        if (count($value['children']) > 0)
            {
            // NIVEL 2
            foreach($value['children'] as $key => $value)
                {
                if (count($value['children']) > 0)
                    {
                    // NIVEL 3
                    foreach($value['children'] as $key => $value)
                        {
                        if (count($value['children']) > 0)
                            {
                                //FOREACH NIVEL 4
                            }else{
                                DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->insert([
                                    'estado'=>'A',
                                    'id_vista'=>$value['id'],
                                    'id_tipo_usuario'=>$id_tipo_usuario->id,
                                    'id_tipo_accion_vistas'=>$value['permisos']['id']
                                    ]);
                            }
                        }
                    }else{
                        DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->insert([
                                    'estado'=>'A',
                                    'id_vista'=>$value['id'],
                                    'id_tipo_usuario'=>$id_tipo_usuario->id,
                                    'id_tipo_accion_vistas'=>$value['permisos']['id']
                                    ]);
                    }
                }
            }else{
                DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->insert([
                            'estado'=>'A',
                            'id_vista'=>$value['id'],
                            'id_tipo_usuario'=>$id_tipo_usuario->id,
                            'id_tipo_accion_vistas'=>$value['permisos']['id']
                            ]);
            }
        }
    }

    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Tipo_Usuarios(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    if ($request->has('filter')&&$request->filter!='') {
        $data=DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')
                                                ->where('nombre','LIKE','%'.$request->input('filter').'%')
                                                //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->where('estado','A')->orderBy('nombre','ASC')->get();
    }else{
        $data=$data=DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->where('estado','A')->orderBy('nombre','ASC')->get();
    }
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Tipo_Usuario(Request $request)
    {
    DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->where('id',$request->id)->update(
        [
         'nombre' => $request->nombre ,
         'descripcion' => $request->descripcion 
         ]);
    DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->where('id_tipo_usuario',$request->id)->delete();
   // return response()->json(['respuesta' => true], 200);
    $id_tipo_usuario=DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->select('id')->where('estado','A')->where('nombre',$request->nombre)->first();
    $array=$request->input('vistas');
    //NIVEL 0
    foreach($array as $key => $value)
    {
        //return response()->json(['respuesta' => $value['children']], 200);
    // NIVEL 1
    foreach($value['children'] as $key => $value)
        {
        if (count($value['children']) > 0)
            {
            // NIVEL 2
            foreach($value['children'] as $key => $value)
                {
                if (count($value['children']) > 0)
                    {
                    // NIVEL 3
                    foreach($value['children'] as $key => $value)
                        {
                        if (count($value['children']) > 0)
                            {
                                //FOREACH NIVEL 4
                            }else{
                                DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->insert([
                                    'estado'=>'A',
                                    'id_vista'=>$value['id'],
                                    'id_tipo_usuario'=>$id_tipo_usuario->id,
                                    'id_tipo_accion_vistas'=>$value['permisos']['id']
                                    ]);
                            }
                        }
                    }else{
                        DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->insert([
                                    'estado'=>'A',
                                    'id_vista'=>$value['id'],
                                    'id_tipo_usuario'=>$id_tipo_usuario->id,
                                    'id_tipo_accion_vistas'=>$value['permisos']['id']
                                    ]);
                    }
                }
            }else{
                DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->insert([
                            'estado'=>'A',
                            'id_vista'=>$value['id'],
                            'id_tipo_usuario'=>$id_tipo_usuario->id,
                            'id_tipo_accion_vistas'=>$value['permisos']['id']
                            ]);
            }
        }
    }
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Vistas_By_Tipo_User(Request $request)
    {
    $campos=['id',
            'nombre',
            'path',
            'url',
            'id_padre'];
        $array=DB::connection($this->name_bdd)->table('administracion.vistas')
        ->select($campos)->where('estado','A')->where('id_padre',0)->get();
        //Combinaciones
        $permisos_default=DB::connection($this->name_bdd)->table('administracion.tipo_accion_vista')
        ->where('estado','A')
        ->where('accion_ver',TRUE)
        ->where('accion_guardar',TRUE)
        ->where('accion_modificar',TRUE)->first();

        $id_padre=$array[0]->id;
        //echo $id_padre;
        $permisos=[];
        //DASH
foreach($array as $key => $value)
    {
    // $value->chi=ldren=[];
    $hijos = DB::connection($this->name_bdd)->table('administracion.vistas')->select($campos)->where('estado', 'A')->where('id_padre', $value->id)->get();
    $value->permisos = $permisos;
    $value->children = $hijos;
    // HIJOS 2
    foreach($value->children as $key => $value)
        {
        $hijos = DB::connection($this->name_bdd)->table('administracion.vistas')->select($campos)->where('estado', 'A')->where('id_padre', $value->id)->get();
        //Permisos
    $permisos=DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->where('estado', 'A')
    ->where('id_vista', $value->id)->where('id_tipo_usuario', $request->id)->where('id_tipo_usuario', $request->id)->first();
    if (count($permisos)>0) {
        $permisos->id_tipo_accion_vistas;
        $permisos=DB::connection($this->name_bdd)->table('administracion.tipo_accion_vista')->where('estado', 'A')
    ->where('id', $permisos->id_tipo_accion_vistas)->first();
    }else{
        $permisos=[];
    }
    
        if (count($hijos) > 0)
            {
            $value->permisos = $permisos;
            $value->children = $hijos;
            // HIJOS 3
            foreach($value->children as $key => $value)
                {
                $hijos = DB::connection($this->name_bdd)->table('administracion.vistas')->select($campos)->where('estado', 'A')->where('id_padre', $value->id)->get();
                //Permisos 
                $permisos=DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->where('estado', 'A')
                    ->where('id_vista', $value->id)->where('id_tipo_usuario', $request->id)->where('id_tipo_usuario', $request->id)->first();
                    if (count($permisos)>0) {
                        $permisos->id_tipo_accion_vistas;
                        $permisos=DB::connection($this->name_bdd)->table('administracion.tipo_accion_vista')->where('estado', 'A')
                    ->where('id', $permisos->id_tipo_accion_vistas)->first();
                    }else{
                        $permisos=[];
                    }
                if (count($hijos) > 0)
                    {
                    $value->permisos = $permisos;
                    $value->children = $hijos;
                    // HIJOS 4
                    foreach($value->children as $key => $value)
                        {
                        $hijos = DB::connection($this->name_bdd)->table('administracion.vistas')->select($campos)->where('estado', 'A')->where('id_padre', $value->id)->get();
                        $permisos=DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')->where('estado', 'A')
                        ->where('id_vista', $value->id)->where('id_tipo_usuario', $request->id)->where('id_tipo_usuario', $request->id)->first();
                        if (count($permisos)>0) {
                            $permisos->id_tipo_accion_vistas;
                            $permisos=DB::connection($this->name_bdd)->table('administracion.tipo_accion_vista')->where('estado', 'A')
                        ->where('id', $permisos->id_tipo_accion_vistas)->first();
                        }else{
                            $permisos=[];
                        }
                        if (count($hijos) > 0)
                            {
                            $value->permisos = $permisos;
                            $value->children = $hijos;
                            }
                          else
                            {
                            $value->permisos = $permisos;
                            $value->children = [];
                            }
                        }
                    }
                  else
                    {
                    $value->permisos = $permisos;
                    $value->children = [];
                    }
                }
            }
          else
            {
            $value->permisos = $permisos;
            $value->children = [];
            }
        }
    }

    return response()->json(['respuesta' => $array], 200);
    }

    public function Delete_Tipo_Usuario(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Combinacion_Privilegios(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('administracion.tipo_accion_vista')->where('estado','A')->get();
    return response()->json(['respuesta' => $data], 200);
    }
    
}

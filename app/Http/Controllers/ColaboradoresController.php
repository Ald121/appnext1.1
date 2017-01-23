<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
use \Firebase\JWT\JWT;
use Config;
use Mail;
use Hash;
// Funciones
use App\libs\Funciones;


class ColaboradoresController extends Controller
{
    public function __construct(Request $request){
        // Funciones
        $this->funciones=new Funciones();
        //Autenticacion
        $key=config('jwt.secret');
        $decoded = JWT::decode($request->token, $key, array('HS256'));
        $this->user=$decoded;
        $this->name_bdd=$this->user->nbdb;
        // Modelos
    }



    public function Existencia_Usuario_Cedula(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('public.personas_documentos_identificacion')->where('estado','A')->where('numero_identificacion',$request->numero_identificacion)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }

    public function Existencia_Usuario_Correo(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('public.personas_correo_electronico')->where('estado','A')->where('correo_electronico',$request->correo_electronico)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }

    public function Existencia_Usuario_Nick(Request $request)
    {
        $existencia=DB::connection($this->name_bdd)->table('usuarios.usuarios')->where('estado','A')->where('nick',$request->nick)->get();
        if (count($existencia)==0) {
            return response()->json(['respuesta' => true], 200);
        }
        return response()->json(['respuesta' => false], 200);
    }

    //---------------------------------- FIN VISTAS -----------
    //---------------------------------- ARRAY VISTAS -----------
    public function Get_array_Vistas()
    {
        $array=[
                ['label'=>'DASH',
                                'path'=>'/Dash',
                                'selected'=>false,
                                'url'=>'dashboard',
                                'children'=>[
                                            [
                                                'label'=>'INICIO',
                                                'path'=>'/Inicio',
                                                'selected'=>true,
                                                'url'=>'dashboard.inicio',
                                                'children'=>[   
                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                            ]
                                            ],
                                            [
                                                'label'=>'PERFIL',
                                                'path'=>'/Perfil',
                                                'selected'=>true,
                                                'url'=>'dashboard.perfil',
                                                'children'=>[   
                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                            ]       
                                            ],
                                            [
                                                'label'=>'APP',
                                                'path'=>'/app',
                                                'selected'=>true,
                                                'url'=>'dashboard.app',
                                                'children'=>[
                                                [
                                                'label'=>'COLABORADORES',
                                                'path'=>'/Colaboradores',
                                                'selected'=>true,
                                                'url'=>'dashboard.colaboradores',
                                                'children'=>[
                                                                [
                                                                    'label'=>'USUARIO',
                                                                    'path'=>'/App/Colaboradores/Usuario',
                                                                    'selected'=>true,
                                                                    'url' =>'dashboard.colaboradores.usuario',
                                                                    'children'=>[   
                                                                                    ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                    ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                    ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                    ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                                ]
                                                                ],
                                                                [
                                                                    'label'=>'TIPO USUARIO',
                                                                    'path'=>'/App/Colaboradores/Tipo_Usuario',
                                                                    'selected'=>true,
                                                                    'url' =>'dashboard.colaboradores.tipo_usuario',
                                                                    'children'=>[   
                                                                                    ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                    ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                    ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                    ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                                ]
                                                                ]
                                                            ]
                                            ],
                                            [
                                                'label'=>'INVENTARIO',
                                                'path'=>'/Inventario',
                                                'selected'=>false,
                                                'url'=>'dashboard.app.inventario',
                                                'children'=>[
                                                            [
                                                                'label'=>'CATEGORIAS',
                                                                'path'=>'/App/Inventario/Categorias',
                                                                'selected'=>true,
                                                                'url' =>'dashboard.inventario.categoria',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'MARCAS',
                                                                'path'=>'/App/Inventario/Marcas',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.marcas',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'MODELOS',
                                                                'path'=>'/App/Inventario/Modelos',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.modelos',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'PRODUCTOS',
                                                                'path'=>'/App/Inventario/Productos',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.productos',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'UBICACION',
                                                                'path'=>'/App/Inventario/Ubicacion',
                                                                'selected'=>false,
                                                                'url'=>'dashboard.inventario.ubicacion',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'GARANTIA',
                                                                'path'=>'/App/Inventario/Garantia',
                                                                'selected'=>false,
                                                                'url'=>'dashboard.inventario.garantia',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'ESTADO_DESCRIPTIVO',
                                                                'path'=>'/App/Inventario/Estado_Descriptivo',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.estado_descriptivo',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            // Parametrizacion Tipos
                                                            [
                                                                'label'=>'TIPO_CATEGORIA',
                                                                'path'=>'/App/Inventario/Tipo_Categoria',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.tipo_categoria',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'TIPO_GARANTIA',
                                                                'path'=>'/App/Inventario/Tipo_Garantia',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.tipo_garantia',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'TIPO_CONSUMO',
                                                                'path'=>'/App/Inventario/Tipo_Consumo',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.tipo_consumo',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'TIPO_PRODUCTOS',
                                                                'path'=>'/App/Inventario/Tipo_Productos',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.tipo_productos',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'TIPO_CATALOGO',
                                                                'path'=>'/App/Inventario/Tipo_Catalogo',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.tipo_catalogo',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ],
                                                            [
                                                                'label'=>'BODEGAS',
                                                                'path'=>'/App/Inventario/Bodegas',
                                                                'selected'=>true,
                                                                'url'=>'dashboard.inventario.bodegas',
                                                                'children'=>[   
                                                                                ['label'=>'Ver','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Crear','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Modificar','selected'=>true,'children'=>[]],
                                                                                ['label'=>'Eliminar','selected'=>true,'children'=>[]]
                                                                            ]
                                                            ]
                                                         ]
                                                ]
                                            ],
                                            ]
                                ]
                                ]  
                    ];
       return $array; 
    }
     //---------------------------------- FIN  VISTAS -----------

    public function Get_Vistas(Request $request)
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
        $vistas=[];
        //DASH
        foreach ($array as $key => $value) {
            //$value->chi=ldren=[];
            $hijos=DB::connection($this->name_bdd)->table('administracion.vistas')
                ->select($campos)->where('estado','A')->where('id_padre',$value->id)->get();
                $value->permisos=$permisos_default;
                $value->children=$hijos;
                //HIJOS 2
                foreach ($value->children as $key => $value) {
                     $hijos=DB::connection($this->name_bdd)->table('administracion.vistas')
                ->select($campos)->where('estado','A')->where('id_padre',$value->id)->get();
                if (count($hijos)>0) {
                    $value->permisos=$permisos_default;
                    $value->children=$hijos;
                    //HIJOS 3
                foreach ($value->children as $key => $value) {
                     $hijos=DB::connection($this->name_bdd)->table('administracion.vistas')
                ->select($campos)->where('estado','A')->where('id_padre',$value->id)->get();
                if (count($hijos)>0) {
                    $value->permisos=$permisos_default;
                    $value->children=$hijos;
                    //HIJOS 4
                    foreach ($value->children as $key => $value) {
                     $hijos=DB::connection($this->name_bdd)->table('administracion.vistas')
                ->select($campos)->where('estado','A')->where('id_padre',$value->id)->get();
                if (count($hijos)>0) {
                    $value->permisos=$permisos_default;
                    $value->children=$hijos;
                }else{
                    $value->permisos=$permisos_default;
                    $value->children=[];
                }
                }
                }else{
                    $value->permisos=$permisos_default;
                    $value->children=[];
                }
                }
                }else{
                    $value->permisos=$permisos_default;
                    $value->children=[];
                }
                
                }
            
        }
       return response()->json(['respuesta' => $array], 200); 
    }

    public function Gen_Vistas_Admin(Request $request)
    {
        $this->Add_Vistas($this->Get_array_Vistas(),$this->name_bdd);
       return response()->json(['respuesta' => true], 200); 
    }

    public function Add_Col_Usuario(Request $request)
    {
    $pass=$this->funciones->generarPass(8);
    DB::connection($this->name_bdd)->table('usuarios.usuarios')->insert(
        [
        'id'=>$this->funciones->generarID(),
        'nick'=>$request->nick.config('global.dominio'),
        'clave_clave'=>bcrypt($pass),
        'id_estado'=>'A',
        'estado_clave'=>TRUE,
        'id_tipo_usuario'=>$request->id_tipo_usuario
        ]);
    $id_usuario=DB::connection($this->name_bdd)->table('usuarios.usuarios')->select('id')->where('nick',$request->nick.config('global.dominio'))->first();
    DB::connection($this->name_bdd)->table('public.personas')->insert(
    [
    'primer_nombre'=>$request->primer_nombre,
     'segundo_nombre'=>$request->segundo_nombre,
     'primer_apellido'=>$request->primer_apellido,
     'segundo_apellido'=>$request->segundo_apellido,
     'id_localidad'=>$request->id_localidad,
     'calle'=>$request->calle,
     'transversal'=>$request->transversal,
     'numero'=>$request->numero_casa,
    ]);
    $id_persona=DB::connection($this->name_bdd)->table('public.personas')->select('id')->where('primer_nombre',$request->primer_nombre)->first();
    //Guardar Correo
    DB::connection($this->name_bdd)->table('public.personas_correo_electronico')->insert(
    [
    'id_persona'=>$id_persona->id,
     'correo_electronico'=>$request->correo_electronico,
     'estado'=>'A'
    ]);
    //Guardar empleado
    DB::connection($this->name_bdd)->table('talento_humano.empleados')->insert(
    [
    'id_persona'=>$id_persona->id,
    'id_usuario'=>$id_usuario->id,
    'estado'=>'A'
    ]);
    /*
    // Guardar DOcumento
    DB::connection($this->name_bdd)->table('public.personas_documentos_identificacion')->insert(
    [
    'id_persona'=>$id_persona->id,
     'id_tipo_documento'=>$request->id_tipo_documento,
     'numero_identificacion'=>$request->numero_identificacion,
     'estado'=>'A'
    ]);
    
    //Guardar Telefono
    DB::connection($this->name_bdd)->table('public.telefonos_personas')->insert(
    [
    'id_persona'=>$id_persona->id,
     'numero'=>$request->numero_telefono,
     'estado'=>'A',
     'id_operadora_telefonica'=>$request->id_operadora_telefonica
    ]);
    //Guardar Usuario
    $pass=$this->funciones->generarPass(8);
    DB::connection($this->name_bdd)->table('usuarios.usuarios')->insert(
    [
    'id'=>$this->funciones->generarID(),
    'nick'=>$request->nick,
    'clave_clave'=>bcrypt($pass),
    'id_estado'=>'A',
    'fecha_creacion'=>$actual_date,
    'estado_clave'=>TRUE,
    'id_tipo_usuario'=>$request->id_tipo_usuario
    ]);*/
    $data = [
                "correo"=>$request->correo_electronico,
                'nombres_apellidos'=>$request->primer_nombre.' '.$request->primer_apellido,
                'user_colaborador'=>$request->nick,
                'pass_colaborador'=>$pass
            ];
    $this->enviar_correo_credenciales($data);

    return response()->json(['respuesta' => true], 200);
    }

    //---------------------------------- INICIO VISTAS -----------
    public function Add_Vistas($array,$bdd_name)
    {

    foreach ($array as $key => $value) {


    DB::connection($this->name_bdd)->table('administracion.vistas')
    ->insert([
         'nombre'=>$value['label'],
        'path'=>$value['path'],
        'url'=>$value['url'],
         'estado'=>'A',
         'id_padre'=>0,
         ]);
    
    $id_padre=DB::connection($bdd_name)->table('administracion.vistas')->select('id')->where('nombre',$value['label'])->first();

        foreach ($value['children'] as $key => $value) {
    
            DB::connection($bdd_name)->table('administracion.vistas')
                ->insert([
                     'nombre'=>$value['label'],
                    'path'=>$value['path'],
                    'url'=>$value['url'],
                     'estado'=>'A',
                     'id_padre'=>$id_padre->id,
           
                     ]);
                $id_padre_2=DB::connection($bdd_name)->table('administracion.vistas')->select('id')->where('nombre',$value['label'])->first();
            if (count($value['children'])>0) {
                foreach ($value['children'] as $key => $value) {
                    
                    if (count($value['children'])>0) {
        
                DB::connection($bdd_name)->table('administracion.vistas')
                    ->insert([
                     'nombre'=>$value['label'],
                    'path'=>$value['path'],
                    'url'=>$value['url'],
                     'estado'=>'A',
                     'id_padre'=>$id_padre_2->id,
           
                     ]);
                    $id_padre_3=DB::connection($bdd_name)->table('administracion.vistas')->select('id')->where('nombre',$value['label'])->first();
                        foreach ($value['children'] as $key => $value) {
        
                    DB::connection($bdd_name)->table('administracion.vistas')
                ->insert([
                     'nombre'=>$value['label'],
                    'path'=>$value['path'],
                    'url'=>$value['url'],
                     'estado'=>'A',
                     'id_padre'=>$id_padre_3->id,
           
                     ]);
                    /*$id_vista=DB::connection($bdd_name)->table('administracion.vistas')->select('id')->where('nombre',$value['label'])->first();
                    DB::connection($this->name_bdd)->table('administracion.usuarios_privilegios')
                        ->insert([
                         'estado'=>'A',
                        'id_vista'=>$id_vista->id,
                        'id_tipo_usuario'=>1,
               
                         ]);*/
                        }
                        
                    }
                }
            }

        }
    }

    return response()->json(['respuesta' => true], 200);
    }

    public function enviar_correo_credenciales($data){
        $correo_enviar=$data['correo'];
        $nombres_apellidos=$data['nombres_apellidos'];
    Mail::send('credenciales_colaborador', $data, function($message)use ($correo_enviar,$nombres_apellidos)
            {
                $message->from("registro@oyefm.com",'Nextbook');
                $message->to($correo_enviar,$nombres_apellidos)->subject('Credenciales de Ingreso');
            });
    }

    public function Get_Col_Usuario(Request $request)
    {
        $currentPage = $request->pagina_actual;
        $limit = $request->limit;
        if ($request->has('filter')&&$request->filter!='') {
            $data=DB::connection($this->name_bdd)->table('usuarios.usuarios')->select('id','nick','id_tipo_usuario')->where('estado','A')
                                                    ->where('label','LIKE','%'.$request->input('filter').'%')
                                                    //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                    ->orderBy('label','ASC')->get();
        }else{
            $data=DB::connection($this->name_bdd)->table('usuarios.usuarios')->select('id','nick','id_tipo_usuario')->where('id_estado','A')->orderBy('nick','ASC')->get();
        }
        foreach ($data as $key => $value) {
            $tipo_usuario=DB::connection($this->name_bdd)->table('usuarios.tipo_usuario')->select('nombre')->where('id',$value->id_tipo_usuario)->first();
            $value->tipo_usuario=$tipo_usuario->nombre;
        }

        $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
        return response()->json(['respuesta' => $data], 200);
    }

    public function Delete_Col_Usuario(Request $request)
    {
        $data=DB::connection($this->name_bdd)->table('usuarios.usuarios')->where('id',$request->id)->update(['id_estado'=>'I']);
        return response()->json(['respuesta' => true], 200);
    }

    public function Get_Col_Usuario_Update(Request $request)
    {   
        $empleado=DB::connection($this->name_bdd)->table('talento_humano.empleados')->select('id_persona')->where('id_usuario',$request->id)->first();
        if (count($empleado)>0) {
        $usuario=DB::connection($this->name_bdd)->table('usuarios.usuarios')->select('nick')->where('id',$request->id)->first();
        $persona=DB::connection($this->name_bdd)->table('public.personas')->where('id',$empleado->id_persona)->first();
        $correo=DB::connection($this->name_bdd)->table('public.personas_correo_electronico')->where('id_persona',$persona->id)->first();
        $ciudad=DB::connection('localidadesconex')->select("SELECT nombre,id,codigo_telefonico FROM view_localidades WHERE id='".$persona->id_localidad."' and nombre!='ECUADOR' ORDER BY nombre ASC");
        $data_nick=explode('@', $usuario->nick);
        $persona->nick=$data_nick[0];
        $persona->id_user=$request->id;
        $persona->id_localidad=$ciudad[0];
        $persona->correo_electronico=$correo->correo_electronico;
        $persona->id_correo=$correo->id;
        return response()->json(['respuesta' => $persona], 200);
        }
        return response()->json(['respuesta' => false], 200);
        
    }

    public function Update_Col_Usuario(Request $request)
    {
    $pass=$this->funciones->generarPass(8);
    DB::connection($this->name_bdd)->table('usuarios.usuarios')->where('id',$request->id_user)->update(
        [
        'nick'=>$request->nick.config('global.dominio'),
        //'clave_clave'=>bcrypt($pass),
        'id_tipo_usuario'=>$request->id_tipo_usuario
        ]);
    DB::connection($this->name_bdd)->table('public.personas')->where('id',$request->id)->update(
    [
    'primer_nombre'=>$request->primer_nombre,
     'segundo_nombre'=>$request->segundo_nombre,
     'primer_apellido'=>$request->primer_apellido,
     'segundo_apellido'=>$request->segundo_apellido,
     'id_localidad'=>$request->id_localidad['id'],
     'calle'=>$request->calle,
     'transversal'=>$request->transversal,
     'numero'=>$request->numero_casa,
    ]);
    //Guardar Correo
    DB::connection($this->name_bdd)->table('public.personas_correo_electronico')->where('id',$request->id_correo)->update(
    [
     'correo_electronico'=>$request->correo_electronico
    ]);
    
   /* $data = [
                "correo"=>$request->correo_electronico,
                'nombres_apellidos'=>$request->primer_nombre.' '.$request->primer_apellido,
                'user_colaborador'=>$request->nick,
                'pass_colaborador'=>$pass
            ];
    $this->enviar_correo_credenciales($data);*/

    return response()->json(['respuesta' => true], 200);
    }
    
}

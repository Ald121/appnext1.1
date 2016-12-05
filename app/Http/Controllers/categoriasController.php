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

class categoriasController extends Controller

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

  public function Add_Categoria(Request $request)
    {
    DB::connection($this->name_bdd)->table('inventario.categorias')->insert(['nombre' => $request->name, 'descripcion' => $request->descripcion, 'tipo_categoria' => $request->tipo_categoria, 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Categorias(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;

    if ($request->has('filter')&&$request->filter!='') {
        //$data=DB::connection($this->name_bdd)->statement("SELECT * FROM inventario.tipos_categorias WHERE (nombre||descripcion) like '%".$request->input('filter')."%' and estado='A' LIMIT 5");
        $data=DB::connection($this->name_bdd)->table('inventario.categorias')
                                                ->where('nombre','LIKE','%'.$request->input('filter').'%')
                                                ->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->where('estado','A')->orderBy('nombre','ASC')->get();
    }else{
        $data=DB::connection($this->name_bdd)->table('inventario.categorias')->where('estado','A')->orderBy('nombre','ASC')->get();
    }
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Categoria(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.categorias')->where('id',$request->id)->update(['nombre' => $request->name , 'descripcion' => $request->descripcion,'tipo_categoria' => $request->tipo_categoria]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Categoria(Request $request)
    {
    $data=DB::connection($this->name_bdd)->table('inventario.categorias')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }

  
  }


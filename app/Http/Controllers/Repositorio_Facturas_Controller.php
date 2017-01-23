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
use App\libs\Funciones_fac;

class Repositorio_Facturas_Controller extends Controller
{

public function __construct(Request $request){
        // Funciones
        $this->funciones=new Funciones();
        $this->Funciones_fac=new Funciones_fac();
        //Autenticacion
        $key=config('jwt.secret');
        $decoded = JWT::decode($request->token, $key, array('HS256'));
        $this->user=$decoded;
        $this->name_bdd=$this->user->nbdb;


    }
    
    public function Leer_Facturas_Correo(Request $request){

      $datos_correo=DB::connection('nextbookconex')->table('empresas')->where('ruc_ci',$this->user->ruc)->first();
      $result_coreo=$this->Funciones_fac->leer($datos_correo->correo_institucional,$datos_correo->clave_correo_institucional,$this->name_bdd);

    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    if ($request->has('filter')&&$request->filter!='') {
        //$data=DB::connection($this->name_bdd)->statement("SELECT * FROM inventario.tipos_categorias WHERE (nombre||descripcion) like '%".$request->input('filter')."%' and estado='A' LIMIT 5");
        $data=DB::connection($this->name_bdd)->table('contabilidad.repositorio_facturas_correo')->where('estado_proceso_factura',FALSE)
                                                ->where('clave_acceso','LIKE','%'.$request->input('filter').'%')
                                                //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->orderBy('id','ASC')->get();
    }else{
        $data=DB::connection($this->name_bdd)->table('contabilidad.repositorio_facturas_correo')->where('estado_proceso_factura',FALSE)->orderBy('id','ASC')->get();
    }
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);

      return response()->json(["respuesta"=>$data]);
        
    }

    public function Get_Facturas_Rechazadas(Request $request){
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    if ($request->has('filter')&&$request->filter!='') {
        //$data=DB::connection($this->name_bdd)->statement("SELECT * FROM inventario.tipos_categorias WHERE (nombre||descripcion) like '%".$request->input('filter')."%' and estado='A' LIMIT 5");
        $data=DB::connection($this->name_bdd)->table('contabilidad.repositorio_facturas_rechazadas')->where('estado','A')
                                                ->where('razon_rechazo','LIKE','%'.$request->input('filter').'%')
                                                //->orwhere('descripcion','LIKE','%'.$request->input('filter').'%')
                                                ->orderBy('id_factura_r','ASC')->get();
    }else{
        $data=DB::connection($this->name_bdd)->table('contabilidad.repositorio_facturas_rechazadas')->where('estado','A')->orderBy('id_factura_r','ASC')->get();
    }
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);

      return response()->json(["respuesta"=>$data]);
        
    }


public function Upload_Factura(Request $request){
        
  $factura=$request->input('factura');

  $impuestos=DB::connection($this->name_bdd)->table('contabilidad.impuestos')->get();
  $subtotal_12=0;


  if ($factura['infoFactura']['totalConImpuestos']['totalImpuesto']['codigo']) {
    $detalle=$factura['infoFactura']['totalConImpuestos']['totalImpuesto'];
    foreach ($impuestos as $key_impuesto => $impuesto) {
        $impuestos[$key_impuesto]->subtotal=0;
      if ($detalle['codigo']==$impuesto->codigo_sri) {
         $impuestos[$key_impuesto]->subtotal=$detalle['baseImponible'];
       } 
    }
  }else{

  foreach ($factura['infoFactura']['totalConImpuestos']['totalImpuesto'] as $key => $detalle) {
    foreach ($impuestos as $key => $impuesto) {
      if ($detalle['codigo']==$impuesto->codigo_sri) {
         $value->subtotal=$detalle['baseImponible'];
       } 
    }

  }

  }

  /*DB::connection($this->name_bdd)->table('contabilidad.repositorio_facturas')->insert([
        'num_factura'=>$factura->['infoTributaria']['estab'].'-'.$factura->['infoTributaria']['ptoEmi'].'-'.$factura->['infoTributaria']['secuencial'],
        'nombre_comercial'=>$factura->['infoTributaria']['nombreComercial'],
        'clave_acceso'=>$factura->['infoTributaria']['claveAcceso'],
        'ruc_prov'=>$factura->['infoTributaria']['ruc'],
       'tipo_doc'=>$factura->['infoTributaria']['codDoc'],
       'total'=>$factura->['infoFactura']['importeTotal'],
       'contenido_fac'=>$factura,
       'id_sucursal'=>$factura->['infoTributaria']['estab'],
       'fecha_emision'=>$factura->['infoFactura']['fechaEmision'],
       'subtotal_12'=>$impuestos[1]->subtotal,
       'subtotal_0'=>$impuestos[0]->subtotal,
       'subtotal_no_sujeto'=>$impuestos[3]->subtotal,
       'subtotal_exento_iva'=>$impuestos[4]->subtotal,
       'subtotal_sin_impuestos'=>$factura->['infoFactura']['totalSinImpuestos'],
       'descuento'=>$factura->['infoFactura']['totalDescuento'],
       'ice'=>'',
       'iva_12'=>$impuestos[1]->valor,
       'propina'=>$factura->['infoFactura']['propina'],
       'estado'=>'A',
       'estado_view'=>TRUE
    ]);*/

        /*foreach ($request->input('totales_tipo_gasto') as $key => $value) {
          echo $value['id'].$value['total'];
        }*/
        
        return response()->json(["respuesta"=>$factura]);
    }

public function Upload_XML(Request $request){
        
        

      return response()->json(["respuesta"=>$request->all()]);
    }

/*public function gen_zip($iduser,$idfac)
        {
            // -------------------------------------------GENERAR PDF ---------------------------------------------------
            $xml = $this->pathLocal.$iduser.$this->pathFacturas.$idfac.".xml";
            $xml = file_get_contents($xml);
            // echo $xml;
            $this->Funciones_fac->gen_pdf($xml,$iduser,$idfac);
            // ----------------------------------------- GENERAR ZIP ----------------------------------------------------
            $xml = glob($this->pathLocal.$iduser.$this->pathFacturas.$idfac.".xml");
            $pdf = glob($this->pathLocal.$iduser.$this->pathFacturas.$idfac.".pdf");
            $zip=Zipper::make($this->pathLocal.$iduser.$this->pathFacturas.$idfac.".zip")->add($xml);
            $resul_zip=$zip->add($pdf);
            if ($resul_zip) {
               return true;
            }
        }
public function update_tipo_consumo(Request $request){
  $update=$this->facturas->where('id_factura',$request->input('id_factura'))->update(['descripcion'=>$request->input('descripcion')]);
  if ($update) {
    return response()->json(['respuesta'=>$request->all()],200);
  }
}

public function get_new_facturas(Request $request){
  $resultado=$this->facturas->where('id_sucursal',$this->id_sucursal)->orderBy('created_at','DESC')->get();

  $nro_sin_leer=$this->facturas->where('id_sucursal',$this->id_sucursal)
                            ->where('estado_view',FALSE)->orderBy('created_at','DESC')->get();

  return response()->json(['respuesta'=>$resultado,'sin_leer'=>count($nro_sin_leer)],200);
}

public function update_estado_view(Request $request){
  $update=$this->facturas->where('id_factura',$request->input('id_factura'))->update(['estado_view'=>TRUE]);
  if ($update) {
      return response()->json(['respuesta'=>true],200);
  }
}*/


}

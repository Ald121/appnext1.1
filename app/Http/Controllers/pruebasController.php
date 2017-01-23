<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use DB;

class pruebasController extends Controller
{
    public function crear_bdd(Request $reuest){
		$name='rivadeneira_1001611381001';
		$pass_user='1001611381001';
    	$create =DB::connection('nextbookconex')->statement('CREATE DATABASE '.$name.' OWNER '.$name.' ');
    	//exec("export PATH=/opt/PostgreSQL/9.5/bin:$PATH", $cmdout_export, $cmdresult_export );
		exec("PGPASSWORD=".$pass_user." psql -U ".$name." -d ".$name." -p 5432 -h localhost < /var/www/html/appnext1.1/postgres/basico.sql", $cmdout, $cmdresult );
    	return response()->json(['respuesta'=>$cmdresult]);
    }
}

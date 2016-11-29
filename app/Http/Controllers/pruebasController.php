<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use DB;

class pruebasController extends Controller
{
    public function crear_bdd(Request $reuest){
		$name='juank';
		$pass_user='1002424735001';
    	$create =DB::connection('nextbookconex')->statement('CREATE DATABASE '.$name.' OWNER '.$name.' ');
		exec("PGPASSWORD=".$pass_user." psql -U ".$name." -d ".$name." -p 5432 -h localhost < /var/www/html/appnext1.1/postgres/basico.sql", $cmdout, $cmdresult );
    	return response()->json(['respuesta'=>$cmdresult]);
    }
}

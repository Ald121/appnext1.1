<?php

namespace App\Http\Middleware;

use Closure;

use App\Usuarios;
use Config;

use \Firebase\JWT\JWT;

class NextbookAuth
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if ($request->token=='') {
            return response(['error'=>'Sin-Token-de-Seguridad'], 401);
        }

        $key=config('jwt.secret');
        $decoded = JWT::decode($request->token, $key, array('HS256'));
        $name_bdd=$decoded->nbdb;
        $pass_bdd=$decoded->pnb;

        Config::set('database.connections.'.$name_bdd, array(
                'driver' => 'pgsql',
                'host' => 'localhost',
                'port' =>  '5432',
                'database' =>  $name_bdd,
                'username' =>  $name_bdd,
                'password' =>  $pass_bdd,
                'charset' => 'utf8',
                'prefix' => '',
                'schema' => 'usuarios',
                'sslmode' => 'prefer',
        ));
        $usuarios=new Usuarios(); 
        $usuarios->changeConnection($name_bdd);
        
        //return response(['datos'=>$decoded]);

        $datos=$usuarios->where('id',$decoded->sub)->get();
        if (count($datos)>0) {
            return $next($request);
        }else{
            return response(['error'=>'Usuario-no-Autorizado'], 401);
        }
        
    }
}

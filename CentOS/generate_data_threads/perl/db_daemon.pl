#!/usr/bin/perl


#!/usr/local/bin/perl

use strict;
use warnings;
use App::Daemon qw( daemonize ); 
use DBI;
use POSIX;
use Email::Send::SMTP::Gmail;
use URI::Encode qw(uri_encode uri_decode);


daemonize();

my $DEBUG = 1;
my $keep_going = 1;


open(STDERR,"> teste.log");

print STDERR "[db_daemon] Starting.... teste 1 \n" if $DEBUG;
print STDERR "[db_daemon] keepgoing value: $keep_going \n" if $DEBUG;

$SIG{HUP}  = sub { $keep_going = 0; finish_daemon(); }; 
$SIG{INT}  = sub { $keep_going = 0; finish_daemon(); };
$SIG{QUIT} = sub { $keep_going = 0; finish_daemon(); };
$SIG{TERM} = sub { $keep_going = 0; finish_daemon(); };

print STDERR "[db_daemon] KeepGoing.... $keep_going  \n" if $DEBUG;


my $dbname = "database";
my $dbusername = "user";
my $dbpass = "password";
my $dbh = DBI->connect("dbi:Pg:dbname=$dbname;host=localhost", $dbusername, $dbpass, {AutoCommit=>1}) || die "Erro DBI->connect: $DBI::errstr\n";
print STDERR "[db_daemon] after DBI->connect (...) \n" if $DEBUG;

my $version = "Versão: 0.03";

my $ok_color = "#1b6d85";
my $warning_color = "#c77c11";
my $critical_color = "#c9302c";


print STDERR "[db_daemon] Gmail connected with error: $error \n" if $DEBUG;
print STDERR "EMAIL session error: $error" unless ($mail!=-1);
print STDERR "[db_daemon] processando fila de envio de alertas... \n" if $DEBUG;
$keep_going = 1;

while ($keep_going) 
{
	my $v_query =  "SELECT    string_agg(cast(a.job_id as text) ,'\n' ORDER BY a.alert_time, a.alert_id) as job_id                 
                                , string_agg(j.job_description,'\n' ORDER BY a.alert_time, a.alert_id) as job_description
                                , string_agg(to_char(a.alert_time,'YYYY-MM-DD HH24:MI:SS'),'\n' ORDER BY a.alert_time, a.alert_id) as alert_time
                                , string_agg(a.alert_severity,'\n' ORDER BY a.alert_time, a.alert_id ) as alert_severity
                                , string_agg(format(j.job_msg1, '<b>' ||a.alert_item || '</b>',
                                 CASE a.alert_severity 
                                  WHEN 'critical'
                                        THEN  '<b style=\"font-weight:bold;font-size:120%;color:" . $critical_color . "\">' || a.alert_value  || '</b>'
                                  WHEN 'warning'
                                        THEN  '<b style=\"font-weight:bold;font-size:120%;color:". $warning_color. "\">' || a.alert_value  || '</b>'
                                  WHEN 'ok'
                                        THEN  '<b style=\"font-weight:bold;font-size:120%;color:". $ok_color . "\">' || a.alert_value  || '</b>'
                                 END
                                   ),'\n' ORDER BY a.alert_time, a.alert_id) as msg_alert 
                                , string_agg(format(j.job_msg2, a.alert_item, a.alert_value),'\n' ORDER BY a.alert_time, a.alert_id) as hint_alert 
                                , string_agg(cast(a.alert_id as text), '\n' ORDER BY a.alert_time, a.alert_id) as alert_id
                                , string_agg(cast(a.instance_id as text), '\n' ORDER BY a.alert_time, a.alert_id) as instance_id
                                , string_agg(cast(a.database_id as text), '\n' ORDER BY a.alert_time, a.alert_id) as database_id
                                , string_agg(trunc(EXTRACT(EPOCH FROM (date_trunc('hour',alert_time) - interval '4 hours')) * 1000)::text, '\n' ORDER BY a.alert_time, a.alert_id) as date_from
                                , string_agg(trunc(EXTRACT(EPOCH FROM (date_trunc('hour',alert_time) + interval '4 hours')) * 1000)::text, '\n' ORDER BY a.alert_time, a.alert_id) as date_to
                                , string_agg(alert_item, '\n' ORDER BY a.alert_time, a.alert_id) as alert_item
                                , string_agg(alert_url, '\n' ORDER BY a.alert_time, a.alert_id) as alert_url
                                , a.customer_id
                                , a.server_id
                                , a.alert_hit
                         FROM     pganalytics.alert a 
                         JOIN     pganalytics.job j USING(job_id)
                        WHERE     a.alert_sent_time IS NULL
                          AND     j.job_type = 'alarm'
                     GROUP BY     a.customer_id, a.server_id, a.alert_hit
                     ORDER BY     min(a.alert_time) ";

	print STDERR "[db_daemon] inside main loop (begin) \n" if $DEBUG;
	my $sth = $dbh->prepare($v_query) || die "Erro DBI->prepare: $DBI::errstr\n";
	$sth->execute() || die "Erro DBI->execute: $DBI::errstr\n";
	while ( my (     $sarr_job_id
			,$sarr_job_description
		    	,$sarr_alert_time
		    	,$sarr_alert_severity
		    	,$sarr_msg_alert
		    	,$sarr_hint_alert
		    	,$sarr_alert_id
		    	,$sarr_instance_id
		    	,$sarr_database_id
		    	,$sarr_date_from
		    	,$sarr_date_to
			,$sarr_alert_item
			,$sarr_alert_url
		    	,$customer_id
		    	,$server_id
		    	,$alert_hit ) =  $sth->fetchrow_array
	      ) 
	{	 
		my ($v_name, $v_email, $v_schema) = get_client_details($customer_id);
		print STDERR ">>>>: " . $v_name . " >>>>: " . $v_email . " >>>>: " . $v_schema . "\n" if $DEBUG; 
		
		my ($server_name, $server_description) = get_server_details($server_id, $v_schema);

		parse_alert( $sarr_job_id
		            ,$sarr_job_description
			   	,$sarr_alert_time
			   	,$sarr_alert_severity
			   	,$sarr_msg_alert
			   	,$sarr_hint_alert
			   	,$sarr_alert_id
			   	,$sarr_instance_id
			   	,$sarr_database_id
		    		,$sarr_date_from
		    		,$sarr_date_to
				,$sarr_alert_item
				,$sarr_alert_url
			   	,$customer_id
			   	,$alert_hit
			   	,$v_name
			   	,$v_email 
			   	,$server_name
			   	,$server_description
			   	,$server_id
			   	,$v_schema);		
	}
	$sth->finish();
	sleep 05;
	print STDERR "[db_daemon] inside main loop (end) \n" if $DEBUG;
}

sub parse_alert
{
	my @se_args = @_;

	my @alert_job_id_array 			= split('\n', $se_args[0] );	
	my @alert_job_description_array 	= split('\n', $se_args[1] );
	my @alert_time_array 			= split('\n', $se_args[2] );
	my @alert_severity_array 		= split('\n', $se_args[3] );
	my @alert_msg_array 			= split('\n', $se_args[4] );
	my @alert_hint_array 			= split('\n', $se_args[5] );
	my @alert_id_array 			= split('\n', $se_args[6] );
	my @alert_instance_id_array 		= split('\n', $se_args[7] );
	my @alert_database_id_array 		= split('\n', $se_args[8] );
	my @alert_date_from_array 		= split('\n', $se_args[9] );
	my @alert_date_to_array 		= split('\n', $se_args[10] );
	my @alert_alert_item_array 		= split('\n', $se_args[11] );
	my @alert_alert_url_array 		= split('\n', $se_args[12] );

	my $customer_id				= $se_args[13];
	my $alert_hit				= $se_args[14];
	my $alert_client_name			= $se_args[15];
	my $alert_client_email			= $se_args[16];
	my $server_name 			= $se_args[17];
	my $server_description 			= $se_args[18];
	my $server_id 				= $se_args[19];	
	my $schema 				= $se_args[20];

	my $email_subject = "[pgAnalytics Alert] $alert_client_name ,  $alert_job_description_array[0] ";
	# my $email_body = "<h3>Email de Alerta Autom&aacute;tico para $alert_client_name / Servidor: $server_name </h3><br><br> ";
	
	my $email_body = '<!-- top -->
<table width="100%" border="0" align="center" cellpadding="5" cellspacing="3" style="padding:20px 0;background-color:#698e95">
        <tbody>
                <tr>
			<td style="text-align:center;vertical-align:middle">
                       		<a href="http://pganalytics.com.br" target="_blank"><img src="http://pganalytics.com.br/img/logo-pganalytics-white.png" alt="pgAnalytics" style="width:180px;height:30px;font-family:Georgia"/></a>
			</td>
		</tr>
        </tbody>
</table>
<table style="padding-bottom:20px;background-color:#white"><tr></tr></table>
<table width="70%" border="0" align="center" cellpadding="5" cellspacing="3" style="border-radius: 7px;background-color:#698e95;color:#53534e;font-size:100%;font-family:arial,helvetica,sans-serif;">
	<tbody> 
		<tr>
			<td colspan="4" style="padding:.1em .3em;background-color:#698e95;color:white;font-size:150%;text-align:center;font-weight:bold">Alertas '. $alert_client_name .':'. $server_name .'</td>
		</tr>
<!-- / top -->';


	print STDERR "Subject: $email_subject \n" if $DEBUG;
	
	for (my $i=0; $i <= $#alert_id_array;  $i++)
	{	
		#my ($v_wid_key, $v_wid_section) = get_job_widgets($alert_job_id_array[$i]);
		#my @arr_extra_params = get_job_extra_params($alert_job_id_array[$i]);
		#my @arr_extra_values = split('\|',$alert_alert_item_array[$i]);

		#my $url_filter = '&filters={';
		#my $extra_param_idx = 0;	
		#foreach my $extra_param (@arr_extra_params)
		#{
			#print STDERR "---> Parâmetro Extra: $extra_param  \n";
			#print STDERR "---> Valor Extra: $arr_extra_values[$extra_param_idx]  \n";
			#if ($extra_param_idx != 0)
			#{
				#$url_filter.= ',';
			#}
			#$url_filter.= "\"$extra_param\":\"$arr_extra_values[$extra_param_idx]\"";
			#$extra_param_idx++;
		#}
		#$url_filter.= '}';

		#my $pga_url = "https://sistemas.pganalytics.com.br/pga/#?customer=".$customer_id."&server=".$server_id."&instance=".$alert_instance_id_array[$i] ."&database=".$alert_database_id_array[$i]."&schema=".$schema."&from=". $alert_date_from_array[$i]."&to=". $alert_date_to_array[$i] ."&chart=". $v_wid_key ."&section=". $v_wid_section ."&alert_id=". $alert_id_array[$i] . $url_filter ;

		my $template_color = "";
		my $template_severity = "";
		if ($alert_severity_array[$i] eq "ok")
		{
			$template_color = $ok_color;
			$template_severity = "Informa&ccedil;&atilde;o";
			$alert_hint_array[$i] = " (OK) "; # Zerar para não mostrar msg quando OK
		}
		elsif ($alert_severity_array[$i] eq "warning")
		{
			$template_color = $warning_color;
			$template_severity = "Aviso";
		}
		elsif ($alert_severity_array[$i] eq "critical")
		{
			$template_color = $critical_color;
			$template_severity = "Cr&iacute;tico";
		}
		my $pga_url = "https://localhost/pga/" . $alert_alert_url_array[$i];

		$email_body .= '<tr>
			<td style="text-align:center;background-color:'.$template_color .';color:white;font-size:100%;border-radius: 7px;font-weight: bold">'.$template_severity.'</td>
			<td style="background-color:white;"><a href="'.uri_encode($pga_url).'" style="color:#428bca">'.$alert_msg_array[$i].'</a></td>
			<td style="background-color:white;"><a href="'.uri_encode($pga_url).'" style="color:#428bca">'.$alert_hint_array[$i].'</a></td>
			<td style="background-color:white;"><a href="'.uri_encode($pga_url).'" style="color:#428bca">'.$alert_time_array[$i].'</a></td>
		</tr>';



		print STDERR "[db_daemon:test_alert: ------- FOR -------- ] itens_id:" 	. $alert_id_array[$i] . "\n" if $DEBUG;
		print STDERR "[db_daemon:test_alert:customer_id] : "          		    . $customer_id  ."\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:server_name] : "          		    . $server_name  ."\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:server_description] : "    		    . $server_description  ."\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:alert_hit] : "            		    . $alert_hit  ."\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:alert_client_name] : "    		    . $alert_client_name ."\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:alert_client_email] : "    		    . $alert_client_email ."\n" if $DEBUG;  

		print STDERR "[db_daemon:test_alert:sarr_job_description] : " . $alert_job_description_array[$i] . "\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:sarr_alert_time] : "      . $alert_time_array[$i] . "\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:sarr_alert_severity] : "  . $alert_severity_array[$i] . "\n" if $DEBUG; 
		print STDERR "[db_daemon:test_alert:sarr_msg_alert] : "       . $alert_msg_array[$i] . "\n" if $DEBUG;  
		print STDERR "[db_daemon:test_alert:sarr_hint_alert] : "      . $alert_hint_array[$i] . "\n" if $DEBUG; 
		print STDERR "[db_daemon:test_alert:sarr_alert_id] : "        . $alert_id_array[$i] . "\n" if $DEBUG;  

	}
	$email_body .= '<!-- footer -->
					</tbody>
				</table>';
	# Verificar a necessidade de montar uma função recursiva.

	#xxx: melhorando o resultado;
	if (send_email($alert_client_email, $email_subject, $email_body) != 1 )
	{
		connect_gmail();
    		send_email($alert_client_email, $email_subject, $email_body) ;
	}

	sleep 15;
	update_alerts_sent_time(@alert_id_array);

}


sub update_alerts_sent_time
{
	my @alerts_id = @_;
	$dbh->begin_work();  
	foreach my $alert_id (@alerts_id)
	{
		my $v_query_update = "UPDATE  pganalytics.alert SET alert_sent_time = clock_timestamp() WHERE  alert_id = $alert_id";
		my $sth2 = $dbh->prepare($v_query_update) || die "Erro DBI->prepare: $DBI::errstr\n";
		$sth2->execute() || die "Erro DBI->execute: $DBI::errstr\n";
		$sth2->finish();
	}
	$dbh->commit();

}

sub get_client_details
{
	my $customer_id = shift;
	my $v_customer_query = "SELECT name, email, schema FROM pganalytics.pm_customer WHERE customer_id = $customer_id";
	my $sth3 = $dbh->prepare($v_customer_query) || die "Erro DBI->prepare: $DBI::errstr\n";
	$sth3->execute() || die "Erro DBI->execute: $DBI::errstr\n";
	my ($v_customer_name, $v_customer_email, $v_schema) =  $sth3->fetchrow_array();
	print STDERR ">>>>" . $v_customer_email . " >>>> " . $v_customer_name . "\n" if $DEBUG; 
	$sth3->finish();

	return ($v_customer_name, $v_customer_email, $v_schema);

}

sub get_server_details
{
	my $server_id = shift;
	my $customer_schema = shift;
	my $v_server_query = "SELECT name, description FROM $customer_schema.pm_server WHERE server_id = $server_id";
	my $sth4 = $dbh->prepare($v_server_query) || die "Erro DBI->prepare: $DBI::errstr\n";
	$sth4->execute() || die "Erro DBI->execute: $DBI::errstr\n";; 
	my ($v_server_name, $v_server_description) = $sth4->fetchrow_array();
	print STDERR "<<<<<<<<" . $v_server_name . "<<<<<<<<" . $v_server_description . "<<<<<<<<" . "\n" if $DEBUG;
	$sth4->finish();

	return ($v_server_name, $v_server_description);

}

sub get_job_widgets
{
	my $p_job_id = shift;
	my $v_widget_has_job_query = "SELECT widgets_key, widgets_section FROM pga_config.widgets_has_job WHERE job_id = $p_job_id LIMIT 1";
	my $sth5 = $dbh->prepare($v_widget_has_job_query) || die "Erro DBI->prepare: $DBI::errstr\n";
	$sth5->execute() || die "Erro DBI->prepare: $DBI::errstr\n";
	my ($v_widgets_key, $v_widgets_section) = $sth5->fetchrow_array();
	print STDERR "#######" . $v_widgets_key . "#######" . $v_widgets_section . "#######" . "\n" if $DEBUG;
	$sth5->finish();

	return ($v_widgets_key, $v_widgets_section);

}

sub get_job_extra_params
{
	my @result_extra_params = ();
	my $p_job_id = shift;
	my $v_get_extra_params = "SELECT ('{\"dummy\":' || json_array_elements(extra_param::json->'change_section'->'params')::text || '}')::json->>'dummy'
				    FROM ( SELECT extra_param  
					     FROM pga_config.widgets 
					    WHERE ( extra_param::json->'change_section'->>'section') = ( SELECT section FROM pga_config.widgets_has_job whj 
                                                                                                           JOIN pga_config.widgets w 
                                                                                                             ON (widgets_key,widgets_section)=(key,section) 
												            AND job_id = $p_job_id )
    					    LIMIT 1
					 ) t ";
	my $sth6 = $dbh->prepare($v_get_extra_params) || die "Erro DBI->prepare: $DBI::errstr\n";
	$sth6->execute() || die "Erro DBI->prepare: $DBI::errstr\n";
	my $count = 0;
	while ( my ($extra_params) = $sth6->fetchrow_array()  ) 
	{
		$result_extra_params[$count] = $extra_params ; 
		$count++;
	}	
	$sth6->finish();

	return @result_extra_params;
}


sub finish_daemon
{
	print STDERR "[db_daemon] disconected from gmail... \n" if $DEBUG;


	print STDERR "[db_daemon] disconecting from database... \n" if $DEBUG;
	$dbh->disconnect();
	print STDERR "[db_daemon] disconected. \n" if $DEBUG;
	close(STDERR);
}



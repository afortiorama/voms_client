# Class defining the ops VO, as seen by the VOMS service.
# Modified version of the CERNOps voms_client
# Uses hieradata hashes. See example for LHC VOs.

class voms_client (
  $vo_vomses = {}
){
  $vos = keys($vo_vomses)
  Voms_directories[$vos] -> Create_files['files']

  voms_directories{$vos:}
  
  create_files{'files': vomses => $vo_vomses}
}

define create_files($vomses = {}){

  $yaml = inline_template('
---
<% @vomses.each_pair do |vo, servers | %>
<% servers.each do |s| -%>
/etc/grid-security/vomsdir/<%= vo %>/<%= s["server"] %>.lsc:
  content: "<%= s["dn"] %>\n<%= s["ca_dn"] %>\n"
  require: File[/etc/grid-security/vomsdir/<%= vo %>]
  
/etc/vomses/<%= vo %>-<%= s["server"] %>:
  content: "\"<%= vo %>\" \"<%= s["server"] %>\" \"<%= s["port"] %>\" \"<%= s["dn"] %>\" \"<%= vo %>\" \"24\"\n"
  require: File[/etc/vomses]
  
<% end -%>
<% end -%>
  ')

   $filedata = parseyaml($yaml)
#   notify {"CCCCC ($filedata)": } 
   create_resources('file',$filedata)
}

define voms_directories(){

  file {"/etc/grid-security/vomsdir/${name}":
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    recurse => true,
    purge   => true,
    require => File['/etc/grid-security/vomsdir']
  }

  # Set defaults for the rest of this scope.
  File{
    owner => root,
    group => root,
    mode  => '0644',
  }

}

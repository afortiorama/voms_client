# Class defining the ops VO, as seen by the VOMS service.
#
# Takes care of all the required setup to enable access to the ATLAS VO
# (users and services) in a grid enabled machine.
#
# == Examples
# 
# Simply enable this class:
#   class{'local::vos::cms':}
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
# CERN IT/PS/PES <it-dep-ps-pes@cern.ch>

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

  ensure_resource('class','voms::install')
  Class[voms::install] -> Voms_directories[$name]
  
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

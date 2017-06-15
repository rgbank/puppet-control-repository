
## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  path   => false,
  #server => $::puppet_server,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

Package { allow_virtual => 'false' }

if $::osfamily == 'windows' {
  File {
    source_permissions => ignore,
  }
}

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default { }


# Docker images
node /^rgbank-web.*dockerbuilder/ {
  include role::rgbank::web_docker
}

# APPLICATIONS
# Site application instances

site {
  # Static application definition
  rgbank { 'dev':
    nodes => {
      Node['rgbank-development'] => {
        [Rgbank::Db['development-db'],Rgbank::Web['development-web']]
      }
    }
  }


  # Dynamic application declarations # from JSON
  # The following code reads a applications.yaml file
  # and creates an instance of each application defined.
  # Format can be:
  # ---
  # <app_type>:
  #   <app_title>:
  #     components:
  #       <component>:
  #         query: <pql query>
  #         ---OR---
  #         nodes:
  #           - <node>
  #           - <node>
  #           - <node>
  #      
  $environment = get_compiler_environment()
  $applications = loadyaml("/etc/puppetlabs/code/environments/${environment}/applications.yaml")

  $applications.each |String $type, $instances| {
    $instances.each |String $title, $params| {

      if $params['parameters'] {
        $param_hash = $params['parameters'].map |$key, $value| {
          {$key => $value}
        }.to_hash
      } else {
        $param_hash = {}
      }

      $component_hash = { 'components' => $params['components'].map |$component, $component_criteria| {
        if ($component_criteria['query']) {
          {$component => puppetdb_query($component_criteria['query']).map |$value| { $value['certname'] }}
        } elsif ($component_criteria['nodes']) {
          {$component => $component_criteria['nodes']}
        }
      }.to_hash  }

      $result = Hash.new( $param_hash + $component_hash)

      create_component_app($type, $title, $result) #<- From the puppetlabs/app_modeling Forge module
    }
  }

  # Dynamic application declarations from hosts themselves.
  # This is fairly advanced.
  # The following code queries all nodes with pp_application defined and
  # if the value of the trusted fact matches a Type[title] format, a
  # new instance of that application will be created.
  # The pp_apptier trusted fact is used to determine which components should
  # be assigned to the node. pp_apptier can be a String or Array of Strings
  $nodes = puppetdb_query('inventory[facts] { fact_contents { path ~> ["trusted","extensions","pp_application"] } and nodes { deactivated is null } }')

  $host_defined_apps = $nodes.map |$node| {
    $node[facts][trusted][extensions][pp_application]
  }.unique

  $host_defined_apps.each |$app| {
    #Skip if the app isn't in the right format
    if !$app.match(/.*\[.*\]/) {
      notice "Skipping application ${app} because it isn't in format Type[title]"
      next()
    }

    $app_type  = $app.split('\[')[0].downcase()
    $app_title = $app.split('\[')[1].chop().downcase()

    #Skip if the app is already defined in the applications.yaml file
    if $applications[$app_type][$app_title] {
      next()
    } else {
      $app_nodes = puppetdb_query("inventory[facts] { facts.trusted.extensions.pp_application = \"${app}\" and nodes { deactivated is null } }")

      #Figure out how many uniqe components we have
      $components = $app_nodes.map |$node| {
        $apptier = $node[facts][trusted][extensions][pp_apptier]

        #The components might be listed as an array in string format
        if ($apptier[0] == '[' and $apptier[-1] == ']') {
          $component_list = $apptier[1,-2].split(',')
        } else {
          $component_list = [$apptier]
        }

        $component_list.map |$comp| {
          {$comp => $node[facts][trusted][certname]}
        }
      }.flatten.to_hash_with_merge

      $components_hash = {'components' => $components}
      create_component_app($app_type, $app_title, $components_hash)
    }
  }
}

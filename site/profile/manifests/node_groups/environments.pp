class profile::node_groups::environments {
	node_group { 'Production environment':
		ensure               => 'present',
    override_environment => true,
		environment          => 'production',
		rule                 => ['=', ['trusted', 'extensions', 'pp_environment'], 'production'],
		parent               => 'All Nodes',
	}

	node_group { 'Staging environment':
		ensure               => 'present',
		environment          => 'staging',
    override_environment => true,
		rule                 => ['=', ['trusted', 'extensions', 'pp_environment'], 'staging'],
		parent               => 'Production environment',
	}

	node_group { 'Dev environment':
		ensure               => 'present',
		environment          => 'dev',
    override_environment => true,
		rule                 => ['=', ['trusted', 'extensions', 'pp_environment'], 'dev'],
		parent               => 'Staging environment',
	}

}

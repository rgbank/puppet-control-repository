class profile::node_groups::environments {
	node_group { 'Production environment':
		ensure               => 'present',
    override_environment => true,
		environment          => 'production',
		rule                 => ['and', ['=', ['trusted', 'extensions', 'environment'], 'production']],
		parent               => 'All Nodes',
	}

	node_group { 'Staging environment':
		ensure               => 'present',
		environment          => 'staging',
    override_environment => true,
		rule                 => ['and', ['=', ['trusted', 'extensions', 'environment'], 'staging']],
		parent               => 'Production environment',
	}

	node_group { 'Dev environment':
		ensure               => 'present',
		environment          => 'dev',
    override_environment => true,
		rule                 => ['and', ['=', ['trusted', 'extensions', 'environment'], 'dev']],
		parent               => 'Staging environment',
	}

}

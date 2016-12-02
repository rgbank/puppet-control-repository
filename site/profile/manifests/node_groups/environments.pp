class profile::node_groups::environments {
	node_group { 'Production environment':
		ensure             => 'present',
    environment_trumps => true,
		environment        => 'production',
		rule               => ['and', ['=', ['trusted', 'extensions', 'environment'], 'production']],
		parent             => 'All Nodes',
	}

	node_group { 'Staging environment':
		ensure             => 'present',
		environment        => 'staging',
    environment_trumps => true,
		rule               => ['and', ['=', ['trusted', 'extensions', 'environment'], 'staging']],
		parent             => 'Production environment',
	}

	node_group { 'Dev environment':
		ensure             => 'present',
		environment        => 'dev',
    environment_trumps => true,
		rule               => ['and', ['=', ['trusted', 'extensions', 'environment'], 'dev']],
		parent             => 'Staging environment',
	}

}

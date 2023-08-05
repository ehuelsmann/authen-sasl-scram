
requires 'perl' => '5.14.0';
requires 'Authen::SCRAM' => '0.011';
requires 'Feature::Compat::Try' => '0.04';

on develop => sub {
    requires 'Test2::V0';
};

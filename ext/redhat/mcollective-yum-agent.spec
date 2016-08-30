Name: mcollective-yum
Version: 0.4
Release: 1%{?dist}
Summary: MCollective Agent for interacting with the `yum` command

Group: System Tools
License: Apache License, Version 2
URL: http://nathanpowell.org/mcollective-yum-agent/
Packager: Nathan Powell
Source: v%{version}.tar.gz
BuildArch: noarch

Requires: mcollective-common

%define plugindir %{_libexecdir}/mcollective/mcollective
%define agentdir %{plugindir}/agent
%define appdir %{plugindir}/application

%description
MCollective Agent for interacting with the `yum` command

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{plugindir}
install -d -m 755 %{buildroot}%{plugindir}/agent
install -d -m 755 %{buildroot}%{plugindir}/application
cp -a agent/yum.rb %{buildroot}%{plugindir}/agent
cp -a agent/yum.ddl %{buildroot}%{plugindir}/agent
cp -a application/yum.rb %{buildroot}%{plugindir}/application


%files
%{plugindir}/agent/yum.rb
%{plugindir}/agent/yum.ddl
%{plugindir}/application/yum.rb

%changelog
* Wed Oct 22 2014 Nathan Powell http://nathanpowell.org
  Initial release

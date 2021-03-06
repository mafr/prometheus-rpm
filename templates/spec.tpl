#############################
# AUTOGENERATED FROM TEMPLATE
#############################
{%- block definitions %}
%define debug_package %{nil}
%define user {{user}}
%define group {{group}}
{% endblock definitions %}

{%- block amble %}
Name:    {{name}}
Version: {{version}}
Release: {{release}}%{?dist}
Summary: {{summary}}
License: {{license}}
URL:     {{URL}}
{% endblock amble %}

{%- block sources %}
{%- for source in sources %}
Source{{loop.index - 1}}: {{source}}
{%- endfor %}
{% endblock sources %}

{%- block requires %}
%{?systemd_requires}
Requires(pre): shadow-utils
%if 0%{?el6} || 0%{?el5}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
%endif
{% endblock requires %}

%description
{%- block description %}
{{description}}
{% endblock description %}

%prep
{%- block prep %}
%setup -q -n {{package}}
{% endblock prep %}

%build
{%- block build %}
/bin/true
{% endblock build %}

%install
{%- block install %}
mkdir -vp %{buildroot}%{_sharedstatedir}/prometheus
install -D -m 755 %{name} %{buildroot}%{_bindir}/%{name}
install -D -m 644 %{SOURCE2} %{buildroot}%{_sysconfdir}/default/%{name}
%if 0%{?el5}
install -D -m 644 %{SOURCE3} %{buildroot}%{_initrddir}/%{name}
%else 
    %if 0%{?el6} 
    install -D -m 644 %{SOURCE3} %{buildroot}%{_initddir}/%{name}
    %else
    install -D -m 644 %{SOURCE1} %{buildroot}%{_unitdir}/%{name}.service
    %endif
%endif
{% endblock install %}

%pre
{%- block pre %}
getent group prometheus >/dev/null || groupadd -r prometheus
getent passwd prometheus >/dev/null || \
  useradd -r -g prometheus -d %{_sharedstatedir}/prometheus -s /sbin/nologin \
          -c "Prometheus services" prometheus
exit 0
{% endblock pre %}

%post
{%- block post %}
%if 0%{?el6} || 0%{?el5}
chkconfig --add %{name}
%else
%systemd_post %{name}.service
%endif
{% endblock post %}

%preun
{%- block preun %}
%if 0%{?el6} || 0%{?el5}
if [ $1 -eq 0 ] ; then
    service %{name} stop > /dev/null 2>&1
    chkconfig --del %{name}
fi
%else
%systemd_preun %{name}.service
%endif
{% endblock preun %}

%postun
{%- block postun %}
%if 0%{?el6} || 0%{?el5} 
if [ "$1" -ge "1" ] ; then
    service %{name} condrestart >/dev/null 2>&1 || :
fi
%else
%systemd_postun %{name}.service
%endif
{% endblock postun %}

%files
{%- block files %}
%defattr(-,root,root,-)
%{_bindir}/%{name}
%config(noreplace) %{_sysconfdir}/default/%{name}
%dir %attr(755, %{user}, %{group}) %{_sharedstatedir}/prometheus
%if 0%{?el5}
%{_initrdddir}/%{name}
%else
    %if 0%{?el6} 
    %{_initddir}/%{name}
    %else
    %{_unitdir}/%{name}.service
    %endif
%endif
{% endblock files %}

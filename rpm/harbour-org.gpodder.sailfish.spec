# Prevent brp-python-bytecompile from running
%define __os_install_post %{___build_post}

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}

Summary:    Media and podcast aggregator
Name:       harbour-org.gpodder.sailfish
Version:    4.18.0
Release:    1
Group:      System/GUI/Other
License:    ISC / GPLv3
BuildArch:  noarch
URL:        http://gpodder.org/
Source0:    %{name}-%{version}.tar.bz2
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.3.0
Requires:   sailfishsilica-qt5
Requires:   libsailfishapp-launcher
Requires:   qml(Amber.Mpris)
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2

%description
gPodder downloads and manages free audio and video content for you.


%prep
%setup -q -n %{name}-%{version}


%build
%qtc_qmake5
%qtc_make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

# >> macros
# Prevent brp-python-bytecompile from running
%define __os_install_post %{___build_post}
# << macros

Summary: Media and podcast aggregator
Name: harbour-org.gpodder.sailfish
Version: 4.7.1
Release: 1
Source: %{name}-%{version}.tar.gz
BuildArch: noarch
URL: http://gpodder.org/
License: ISC / GPLv3
Group: System/GUI/Other
Requires: pyotherside-qml-plugin-python3-qt5 >= 1.3.0
Requires: sailfishsilica-qt5
Requires: libsailfishapp-launcher
Requires: mpris-qt5

%description
gPodder downloads and manages free audio and video content for you.

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre



# >> build post
# << build post

%install
rm -rf %{buildroot}
%qmake5_install
# >> install pre
# << install pre

# >> install post
# << install post

%post

%postun

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files

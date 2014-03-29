# Prevent brp-python-bytecompile from running
%define __os_install_post %{___build_post}

Summary: Media and podcast aggregator
Name: harbour-org.gpodder.sailfish
Version: 4.1.0
Release: 1
Source0: %{name}-%{version}.tar.gz
Source1: %{name}.desktop
Source2: %{name}.png
BuildArch: noarch
URL: http://gpodder.org/
License: ISC / GPLv3
Group: System/GUI/Other
Requires: pyotherside-qml-plugin-python3-qt5
Requires: sailfishsilica-qt5
Requires: libsailfishapp-launcher

%description
gPodder downloads and manages free audio and video content for you.

%prep
%setup -q

%build
# Nothing to do

%install

TARGET=%{buildroot}/%{_datadir}/%{name}
mkdir -p $TARGET
cp -rpv gpodder-core/src/* $TARGET/
cp -rpv podcastparser/podcastparser.py $TARGET/
cp -rpv gpodder-ui-qml/main.py $TARGET/
cp -rpv qml $TARGET/
cp -rpv gpodder-ui-qml/common $TARGET/qml/

TARGET=%{buildroot}/%{_datadir}/applications
mkdir -p $TARGET
cp -rpv %{SOURCE1} $TARGET/

TARGET=%{buildroot}/%{_datadir}/icons/hicolor/86x86/apps/
mkdir -p $TARGET
cp -rpv %{SOURCE2} $TARGET/

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

# FIXME: building elements in shared mode causes them to drag in the entire
#   dependencies of psimedia

CONFIG -= debug_and_release debug release

include(../conf.pri)

windows {
	CONFIG += release

	GSTBUNDLE_PREFIX=c:/gstbundle/i386
	DXSDK_PREFIX=c:/dxsdk
	DXMINGW_PREFIX=c:/dxmingw
	#DXMINGW_PREFIX=c:/dxsdk_sum2004
	#-L$$DXMINGW_PREFIX/Lib/x64 \

	INCLUDEPATH += \
		$$GSTBUNDLE_PREFIX/include/glib-2.0 \
		$$GSTBUNDLE_PREFIX/lib/glib-2.0/include \
		$$GSTBUNDLE_PREFIX/include \
		$$GSTBUNDLE_PREFIX/include/gstreamer-0.10 \
		$$DXSDK_PREFIX/include \
		$$DXMINGW_PREFIX/include
	LIBS += \
		-L$$GSTBUNDLE_PREFIX/lib \
		-lgstreamer-0.10.dll \
		-lgthread-2.0 \
		-lglib-2.0 \
		-lgobject-2.0 \
		-lgstvideo-0.10.dll \
		-lgstbase-0.10.dll \
		-lgstinterfaces-0.10.dll

	# qmake mingw seems to have broken prl support, so force these
	win32-g++|contains($$list($$[QT_VERSION]), 4.0.*|4.1.*|4.2.*|4.8.*) {
		LIBS *= \
			-lgstaudio-0.10.dll \
			-lgstrtp-0.10.dll \
			-lgstnetbuffer-0.10.dll \
			-lspeexdsp \
			-lsetupapi \
			-ldsound \
			-ldxerr9 \
			-lole32
	}
			#-lamstrmid \
			#-lksuser \
}

unix {
	LIBS += -lgstvideo-0.10 -lgstinterfaces-0.10
}

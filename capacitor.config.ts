import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'no.minio.app',
  appName: 'Minio',
  server: {
    url: 'https://minio.no',
    cleartext: false,
  },
  plugins: {
    SplashScreen: {
      launchAutoHide: true,
      iosPresentStyle: 'auto',
      backgroundColor: '#202020',
      androidSplashResourceName: 'splash',
      androidScaleType: 'CENTER_CROP',
      showSpinner: false,
      splashFullScreen: true,
      splashImmersive: true,
    },
  },
};

export default config;

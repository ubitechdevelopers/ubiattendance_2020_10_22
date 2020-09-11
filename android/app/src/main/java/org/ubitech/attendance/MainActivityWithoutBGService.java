package org.ubitech.attendance;

import android.Manifest;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.StrictMode;
import android.provider.Settings;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.work.ExistingWorkPolicy;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;

import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnCanceledListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Timer;
import java.util.concurrent.TimeUnit;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivityWithoutBGService extends FlutterActivity {

  private LocationAssistant assistant;
  private static final String CHANNEL = "location.spoofing.check";
  private static final String CAMERA_CHANNEL = "update.camera.status";
  private static final String FACEBOOK_CHANNEL = "log.facebook.data";
  private boolean cameraOpened=false;
  private BackgroundLocationService gpsService;
  private Location mCurrentLocation;


  private SettingsClient mSettingsClient;
  private LocationSettingsRequest mLocationSettingsRequest;
  private static final int REQUEST_CHECK_SETTINGS = 214;
  private static final int REQUEST_ENABLE_GPS = 516;

  private FusedLocationProviderClient fusedLocationClient;


  MethodChannel channel;
    private boolean mockLocationsEnabled=false;
    private Location lastMockLocation;
    private int numGoodReadings=0;
    private LocationRequest locationRequest;
    private LocationCallback locationCallback;

    protected void createLocationRequest() {
        LocationRequest locationRequest = LocationRequest.create();
        locationRequest.setInterval(10000);
        locationRequest.setFastestInterval(5000);
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
    }

    private void startLocationUpdates() {
        /*
        fusedLocationClient.requestLocationUpdates(locationRequest,
                locationCallback,
                Looper.getMainLooper());*/
    }

    private void checkMockLocations() {
        // Starting with API level >= 18 we can (partially) rely on .isFromMockProvider()
        // (http://developer.android.com/reference/android/location/Location.html#isFromMockProvider%28%29)
        // For API level < 18 we have to check the Settings.Secure flag
        //checkInternet();
        if (Build.VERSION.SDK_INT < 18 &&
                !Settings.Secure.getString(getApplicationContext().getContentResolver(), Settings
                        .Secure.ALLOW_MOCK_LOCATION).equals("0")) {
            mockLocationsEnabled = true;

        } else
            mockLocationsEnabled = false;

        android.util.Log.i("shashank","checking Mock Location "+mockLocationsEnabled);
    }

    private boolean isLocationPlausible(Location location) {
        checkMockLocations();
        if (location == null) return false;

        boolean isMock = mockLocationsEnabled || (Build.VERSION.SDK_INT >= 18 && location.isFromMockProvider());
        if (isMock) {
            lastMockLocation = location;
            numGoodReadings = 0;
        } else
            numGoodReadings = Math.min(numGoodReadings + 1, 1000000); // Prevent overflow

        // We only clear that incident record after a significant show of good behavior
        if (numGoodReadings >= 20) lastMockLocation = null;

        // If there's nothing to compare against, we have to trust it
        if (lastMockLocation == null) return true;

        // And finally, if it's more than 1km away from the last known mock, we'll trust it
        double d = location.distanceTo(lastMockLocation);
        return (d > 1000);
    }

    public void updateLocationToFlutter(MethodChannel channel,Location mLastLocation){


        long previousTime=0,currentTime=0;

        boolean timeSpoofed=false;
        boolean plausible;
        String ifMocked="";
        HashMap<String, String> responseMap = new HashMap<String, String>();
        //android.util.Log.i("LocationWOService", "LocationChanged: "+location);
        if(isLocationPlausible(mLastLocation)){
            plausible=true;
            android.util.Log.i("shashank","Plausible");
            ifMocked = "No";
        }
        else{
            plausible=false;
            ifMocked = "Yes";
            android.util.Log.i("shashank","Not Plausible");
        }

        android.util.Log.i("TimeFromLocation",mLastLocation.getTime()+"");
        if (String.valueOf(mLastLocation.getTime()) != null){
            currentTime= TimeUnit.MILLISECONDS.toMinutes(mLastLocation.getTime());
            if(previousTime!=0&&!timeSpoofed){
                if((currentTime-previousTime)>10||(currentTime-previousTime)<-10){
                    timeSpoofed=true;
                    android.util.Log.i("TimeSpoofed","detected");
                }

            }
            previousTime=currentTime;

        }

        if (String.valueOf(mLastLocation.getLatitude()) != null)
            responseMap.put("latitude", String.valueOf(mLastLocation.getLatitude()));
        if (String.valueOf(mLastLocation.getLongitude()) != null)
            responseMap.put("longitude", String.valueOf(mLastLocation.getLongitude()));
        responseMap.put("internet", "Internet Available");

        responseMap.put("mocked", ifMocked);
        responseMap.put("TimeSpoofed", timeSpoofed?"Yes":"No");

        channel.invokeMethod("locationAndInternet", responseMap);

        android.util.Log.i(getClass().getSimpleName(), " Lat: " + responseMap.get("latitude") + " Longi: " + responseMap.get("longitude"));



    }


  //LocationListenerExecuter listenerExecuter;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

      Log.i("Dialog","hdghdgjdgjdgdjgdjgdjggggggg");

      channel=new MethodChannel(getFlutterView(), CHANNEL);
      fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
      for(int ij=0;ij<10;ij++){
          fusedLocationClient.getLastLocation()
                  .addOnSuccessListener(this, new OnSuccessListener<Location>() {
                      @Override
                      public void onSuccess(Location location) {
                          // Got last known location. In some rare situations this can be null.
                          if (location != null) {

                              mCurrentLocation=location;
                              //if(mCurrentLocation.hasAccuracy())
                                  updateLocationToFlutter(channel,mCurrentLocation);

                          }
                      }
                  });
      }

      locationRequest = LocationRequest.create();
      locationRequest.setInterval(10000);
      locationRequest.setFastestInterval(5000);
      locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
      locationCallback = new LocationCallback() {
          @Override
          public void onLocationResult(LocationResult locationResult) {
              if (locationResult == null) {
                  return;
              }
              for (Location location : locationResult.getLocations()) {
                  mCurrentLocation=location;
                  if(mCurrentLocation.hasAccuracy())
                  updateLocationToFlutter(channel,mCurrentLocation);
              }
          };
      };

      fusedLocationClient.requestLocationUpdates(locationRequest,
              locationCallback,
              Looper.getMainLooper());


/*
      Intent i=getIntent();
      final Handler handler = new Handler();
      handler.postDelayed(new Runnable() {
          @Override
          public void run() {
              onNewIntent(i);
          }
      }, 7000);

    //onNewIntent(i);
*/

  //showLocationDialog();
   // FacebookEventLoggers facebookLogger=new FacebookEventLoggers(getApplicationContext());
/*
      Intent intent1 = new Intent();

      String manufacturer = android.os.Build.MANUFACTURER;

      switch (manufacturer) {

          case "xiaomi":
              intent1.setComponent(new ComponentName("com.miui.securitycenter",
                      "com.miui.permcenter.autostart.AutoStartManagementActivity"));
              break;
          case "oppo":
              intent1.setComponent(new ComponentName("com.coloros.safecenter",
                      "com.coloros.safecenter.permission.startup.StartupAppListActivity"));

              break;
          case "vivo":
              intent1.setComponent(new ComponentName("com.vivo.permissionmanager",
                      "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"));
              break;
      }

      List<ResolveInfo> arrayList =  getPackageManager().queryIntentActivities(intent1,
              PackageManager.MATCH_DEFAULT_ONLY);

      if (arrayList.size() > 0) {
          startActivity(intent1);
      }
*/

/*
      Intent intent111 = new Intent(getApplicationContext(), MainActivity.class);
      intent111.setAction(Intent.ACTION_RUN);
      intent111.putExtra("route", "settings");
      intent111.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      getApplicationContext().startActivity(intent111);
*/


    MethodChannel facebookChannel=new MethodChannel(getFlutterView(), FACEBOOK_CHANNEL);

    //facebookLogger.logCompleteRegistrationEvent("");
    //facebookLogger.logContactEvent();
    //facebookLogger.logPurchaseEvent();
    //facebookLogger.logRateEvent("","","0",5,4);
    //facebookLogger.logStartTrialEvent("","",0.0);
    facebookChannel.setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("logCompleteRegistrationEvent")) {
                  //if(facebookLogger!=null);
                 // facebookLogger.logCompleteRegistrationEvent("");
                }
                else
                if (call.method.equals("logContactEvent")) {
                  //if(facebookLogger!=null);
                 // facebookLogger.logContactEvent();
                }
                else
                if (call.method.equals("logPurchaseEvent")) {
                 // if(facebookLogger!=null);
                // facebookLogger.logPurchaseEvent();
                }
                if (call.method.equals("logRateEvent")) {
                  // Log.i("Assistant","Assistant Start Called");
                 // if(facebookLogger!=null);
                 // facebookLogger.logRateEvent("","","0",5,4);
                }
                if (call.method.equals("logStartTrialEvent")) {
                //  if(facebookLogger!=null);
                // facebookLogger.logStartTrialEvent("","",0.0);

                }

              }
            });



      ActivityCompat.requestPermissions(this,
             new String[]{/*Manifest.permission.CAMERA,*/Manifest.permission.ACCESS_FINE_LOCATION,/*Manifest.permission.WRITE_EXTERNAL_STORAGE,Manifest.permission.READ_CONTACTS*/}, 1);










    /*

     if (android.os.Build.VERSION.SDK_INT > 9)
    {
      StrictMode.ThreadPolicy policy = new
              StrictMode.ThreadPolicy.Builder().permitAll().build();
      StrictMode.setThreadPolicy(policy);
    }
    try{
        final Intent intent = new Intent(this.getApplication(), BackgroundLocationService.class);
        this.getApplication().startService(intent);

        //this.getApplication().startForegroundService(intent);

     this.getApplication().bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);


    }
    catch(Exception e){
        Log.e("AsyncTask",e.getMessage());
    }
      Timer timer = new Timer();
*/
      new MethodChannel(getFlutterView(), CAMERA_CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("cameraOpened")) {
                  cameraOpened=true;
                  Log.i("camera","camera opened true");
                  try{
                      /*
                  if(listenerExecuter!=null)
                 listenerExecuter.updateCameraStatus(true);
                  */
                  }

                  catch(Exception e){

                  }
                }
                else
                if (call.method.equals("cameraClosed")) {
                    Log.i("camera","camera opened false");
                    cameraOpened=false;
                    try{
                      /*
                  if(listenerExecuter!=null)
                  listenerExecuter.updateCameraStatus(false);

                       */
                    }
                    catch(Exception e){

                    }
                }
                else
                if (call.method.equals("askAudioPermission")) {
                    Log.i("audio","permission asked");
                    try{

                        ActivityCompat.requestPermissions(MainActivityWithoutBGService.this,
                                new String[]{Manifest.permission.RECORD_AUDIO}, 444);



                      /*
                  if(listenerExecuter!=null)
                  listenerExecuter.updateCameraStatus(false);

                       */
                    }
                    catch(Exception e){

                    }
                }
                else
                if (call.method.equals("startAssistant")) {
                  Log.i("Assistant","Assistant Start Called");

                  manuallyStartAssistant();
                }else
                if (call.method.equals("startTimeOutNotificationWorker")) {
                  // Log.i("Assistant","Assistant Start Called");
                 // WorkManager.getInstance().cancelAllWorkByTag("TimeInWork");// Cancel time in work if scheduled previously
                  //String ShiftTimeOut = call.argument("ShiftTimeOut");
                  //Log.i("ShiftTimeout",ShiftTimeOut);
                  //startTimeOutNotificationWorker(ShiftTimeOut);
                }else
                if (call.method.equals("startTimeInNotificationWorker")) {
                  // Log.i("Assistant","Assistant Start Called");
                  //WorkManager.getInstance().cancelAllWorkByTag("TimeOutWork");// Cancel time out work if scheduled previously
                 // String ShiftTimeIn = call.argument("ShiftTimeIn");
                   // String nextWorkingDay = call.argument("nextWorkingDay");
                 // Log.i("nextWorkingDay",nextWorkingDay);
                 // startTimeInNotificationWorker(ShiftTimeIn,nextWorkingDay);
                }else
                if (call.method.equals("openLocationDialog")) {
                  openLocationDialog();
                }
                else if (call.method.equals("showNotification")) {

                    String notiTitle = call.argument("title");
                    String notiDescription = call.argument("description");
                    String pageToOpenOnClick = call.argument("pageToOpenOnClick");

                    DisplayNotification displayNotification=new DisplayNotification(getApplicationContext());

                    displayNotification.displayNotification(notiTitle,notiDescription,pageToOpenOnClick);
                }

              }
            });



  }
  /*
    public static boolean isServiceRunningInForeground(Context context, Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                if (service.foreground) {
                    return true;
                }

            }
        }
        return false;
    }
    private ServiceConnection serviceConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            String name = className.getClassName();
            Log.i("abc","serviceConnected "+name);
            if (name.endsWith("BackgroundLocationService")) {
                gpsService = ((BackgroundLocationService.LocationServiceBinder) service).getService();

                    gpsService.startTracking(channel);


            }
        }

        public void onServiceDisconnected(ComponentName className) {
            if (className.getClassName().equals("BackgroundLocationService")) {
                gpsService = null;
            }
        }
    };

    public static void triggerRebirth(Context context) {
        PackageManager packageManager = context.getPackageManager();
        Intent intent = packageManager.getLaunchIntentForPackage(context.getPackageName());
        ComponentName componentName = intent.getComponent();
        Intent mainIntent = Intent.makeRestartActivityTask(componentName);
        context.startActivity(mainIntent);
        Runtime.getRuntime().exit(0);
    }
*/

  public void openLocationDialog(){


    LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
    builder.addLocationRequest(new LocationRequest().setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY));
    builder.setAlwaysShow(true);
    mLocationSettingsRequest = builder.build();

    mSettingsClient = LocationServices.getSettingsClient(MainActivityWithoutBGService.this);

    mSettingsClient
            .checkLocationSettings(mLocationSettingsRequest)
            .addOnSuccessListener(new OnSuccessListener<LocationSettingsResponse>() {
              @Override
              public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
                //Success Perform Task Here
              }
            })
            .addOnFailureListener(new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                int statusCode = ((ApiException) e).getStatusCode();
                switch (statusCode) {
                  case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                    try {
                      ResolvableApiException rae = (ResolvableApiException) e;
                      rae.startResolutionForResult(MainActivityWithoutBGService.this, REQUEST_CHECK_SETTINGS);
                    } catch (IntentSender.SendIntentException sie) {
                      Log.e("GPS","Unable to execute request.");
                    }
                    break;
                  case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                    Log.e("GPS","Location settings are inadequate, and cannot be fixed here. Fix in Settings.");
                }
              }
            })
            .addOnCanceledListener(new OnCanceledListener() {
              @Override
              public void onCanceled() {
                Log.e("GPS","checkLocationSettings -> onCanceled");
              }
            });



  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    if (requestCode == REQUEST_CHECK_SETTINGS) {
      switch (resultCode) {
        case Activity.RESULT_OK:
          //Success Perform Task Here
          manuallyStartAssistant();
          break;
        case Activity.RESULT_CANCELED:
          Log.e("GPS","User denied to access location");
          openLocationDialog();
          break;
      }
    } else if (requestCode == REQUEST_ENABLE_GPS) {
      LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
      boolean isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);

      if (!isGpsEnabled) {
        openLocationDialog();
      } else {

        //navigateToUser();
       // manuallyStartAssistant();
      }
    }
    else if(requestCode==444){
    /*    Log.i("request code",""+requestCode);
        triggerRebirth(MainActivity.this);
*/
    }
  }

  private void openGpsEnableSetting() {
    Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
    startActivityForResult(intent, REQUEST_ENABLE_GPS);
  }



  public void startTimeOutNotificationWorker(String ShiftTimeOut) {
      /*
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
    String currentTime=sdf.format(cal.getTime());
    Log.i("DateShashank",currentTime+"");

    SimpleDateFormat format = new SimpleDateFormat("HH:mm:ss");
    Date date1 = null,date2=null;
    long minutes=0;
    try {
      date1 = format.parse(ShiftTimeOut);
      date2 = format.parse(currentTime);
      long differenceinMilli = date1.getTime()- date2.getTime();
      minutes = TimeUnit.MILLISECONDS.toMinutes(differenceinMilli);
      Log.i("differenceinMilli",differenceinMilli+"");
      Log.i("minutes",minutes+"");
      if(minutes<0){
        minutes=0;
      }
      else{
        minutes=minutes+5;
      }
    } catch (ParseException e) {
      Log.i("TimeError","Time not correct when calculating worker interval");
      e.printStackTrace();
    }


Log.i("WorkerMinutesForTimeOut",minutes+"");
  final OneTimeWorkRequest workRequest = new OneTimeWorkRequest.Builder(TimeOutNotificationWork.class)
          .setInitialDelay(minutes, TimeUnit.MINUTES)
          .addTag("TimeOutWork")
          .build();
  WorkManager.getInstance().enqueue(workRequest);


       */
  }

  public void startTimeInNotificationWorker(String ShiftTimeIn,String nextWorkingDay){
      /*
    Calendar cal = Calendar.getInstance();
    Log.i("nextWorkingday",nextWorkingDay);
      String dateStart = nextWorkingDay+" "+ShiftTimeIn;
      String dateStop = "01/15/2012 10:31:48";

      //HH converts hour in 24 hours format (0-23), day calculation
      SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");

      Date d1 = null;
      Date d2 = null;
      long diffMinutes=0;
      try {
          d1 = format.parse(dateStart);
          d2 =  new Date(System.currentTimeMillis());

          //in milliseconds
          long diff =  d1.getTime()-d2.getTime() ;
           Log.i("diff",diff+"");
          long diffSeconds = diff / 1000 % 60;
          diffMinutes = diff / (60 * 1000) % 60;
          long diffHours = diff / (60 * 60 * 1000) % 24;
          long diffDays = diff / (24 * 60 * 60 * 1000);
         diffMinutes = diffMinutes+diffDays*1440+diffHours*60;
          if(diffMinutes<0){
            diffMinutes=0;
          }
          else{
            diffMinutes=diffMinutes+5;
          }

      } catch (Exception e) {
          e.printStackTrace();
      }














    Log.i("WorkerMinutesForTimeIn",diffMinutes+"");
    final OneTimeWorkRequest workRequest = new OneTimeWorkRequest.Builder(TimeInNotificationWork.class)
            .setInitialDelay(diffMinutes, TimeUnit.MINUTES)
            .addTag("TimeInWork")
            .build()
            ;



      WorkManager w=WorkManager.getInstance();
      w.enqueueUniqueWork("TimeInNotificationWork", ExistingWorkPolicy.KEEP,workRequest);


       */
  }


  public void manuallyStartAssistant(){
    try{
        onPause();
        onResume();
    }
    catch(Exception e){

    }
  }

  @Override
  public void onDestroy() {
    try{
    if(gpsService!=null)
    gpsService.stopTracking();
    }
    catch(Exception e){

    }
    super.onDestroy();

  }
  @Override
  protected void onResume() {
    super.onResume();
    try{



        for(int ij=0;ij<10;ij++){
            fusedLocationClient.getLastLocation()
                    .addOnSuccessListener(this, new OnSuccessListener<Location>() {
                        @Override
                        public void onSuccess(Location location) {
                            // Got last known location. In some rare situations this can be null.
                            if (location != null) {

                                mCurrentLocation=location;
                                //if(mCurrentLocation.hasAccuracy())
                                updateLocationToFlutter(channel,mCurrentLocation);

                            }
                        }
                    });
        }

       fusedLocationClient.requestLocationUpdates(locationRequest,
               locationCallback,
               Looper.getMainLooper());

    }
    catch(Exception e){

    }
     // assistant.start();
  }

  @Override
  protected void onPause() {
   // assistant.stop();
  //if(!cameraOpened)
      super.onPause();
    try {
        fusedLocationClient.removeLocationUpdates(locationCallback);

    }
    catch(Exception e){

    }
    //super.onPause();
  }





  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
      super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if(permissions!=null&&permissions.length>0) {
      for (int i = 0; i < permissions.length; i++) {

try{
        if (permissions[i].equals(Manifest.permission.ACCESS_FINE_LOCATION)&&gpsService!=null) {
          Log.i("Peeeerrrr", requestCode + "detected");
            fusedLocationClient.requestLocationUpdates(locationRequest,
                    locationCallback,
                    Looper.getMainLooper());

        }
}
catch(Exception e){

}

      }
    }

  // Log.i("Perrrrr",permissions[1]+grantResults);

  }


    @Override
    public void onNewIntent(Intent intent){
        Bundle extras = intent.getExtras();

  Log.e("INTENT","Notification Recieved");


        if(extras != null){
            if(extras.containsKey("whereToGo"))
            {
                Log.i("WhereToGo",extras.getString("whereToGo"));
                HashMap<String, String> responseMap = new HashMap<String, String>();
                responseMap.put("page",extras.getString("whereToGo"));
                if(channel!=null){
                    channel.invokeMethod("navigateToPage", responseMap);
                    Log.i("togo","akah"+extras.getString("whereToGo"));
                }
            }
        }


    }

}

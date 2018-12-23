
package com.alopeyk.nativemodule.snackbar;

import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Build;
import android.support.design.widget.Snackbar;
import android.support.v4.view.ViewCompat;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.alopeyk.nativemodule.snackbar.topsnackbar.TSnackbar;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.views.text.ReactFontManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.alopeyk.nativemodule.snackbar.R;

public class RNSnackbarModule extends ReactContextBaseJavaModule {
  private static final String REACT_NAME = "Snackbar";
  private static final int BAR_POSITION_BOTTOM = 1;
  private static final int BAR_POSITION_TOP = 2;
  private List<Snackbar> bottomActiveSnackbars = new ArrayList<>();
  private List<TSnackbar> topActiveSnackbars = new ArrayList<>();

  public RNSnackbarModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return REACT_NAME;
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();

    constants.put("LENGTH_LONG", Snackbar.LENGTH_LONG);
    constants.put("LENGTH_SHORT", Snackbar.LENGTH_SHORT);
    constants.put("LENGTH_INDEFINITE", Snackbar.LENGTH_INDEFINITE);
    constants.put("DIRECTION_LTR", ViewCompat.LAYOUT_DIRECTION_LTR);
    constants.put("DIRECTION_RTL", ViewCompat.LAYOUT_DIRECTION_RTL);
    constants.put("BAR_POSITION_BOTTOM", BAR_POSITION_BOTTOM);
    constants.put("BAR_POSITION_TOP", BAR_POSITION_TOP);

    return constants;
  }


  @ReactMethod
  public void show(ReadableMap options, Callback callback){
    ViewGroup view;

    try {
      view = getCurrentActivity().getWindow().getDecorView().findViewById(android.R.id.content);
    } catch (Exception e) {
      e.printStackTrace();
      return;
    }

    if (view == null) return;

    bottomActiveSnackbars.clear();
    topActiveSnackbars.clear();

    if (!view.hasWindowFocus()) {
      // The view is not focused, we should get all the modal views in the screen.
      ArrayList<View> modals = recursiveLoopChildren(view, new ArrayList<View>());

      for (View modalViews : modals) {
        displaySnackbar(modalViews, options, callback);
      }

      return;
    }

    displaySnackbar(view, options, callback);
  }

  @ReactMethod
  public void dismiss() {
    for (Snackbar snackbar : bottomActiveSnackbars) {
      if (snackbar != null) {
        snackbar.dismiss();
      }
    }

    for (TSnackbar tSnackbar : topActiveSnackbars) {
      if (tSnackbar != null) {
        tSnackbar.dismiss();
      }
    }

    bottomActiveSnackbars.clear();
    topActiveSnackbars.clear();
  }

  private void displaySnackbar(View view, ReadableMap options, final Callback callback) {
    String title = options.hasKey("title") ? options.getString("title") : "";
    int duration = options.hasKey("duration") ? options.getInt("duration") : Snackbar.LENGTH_SHORT;

    if(options.hasKey("barPosition") && options.getInt("barPosition") == BAR_POSITION_TOP){
      displayTopSnackbar(view, options, callback, title, duration);
    }else{
      displayBottomSnackbar(view, options, callback, title, duration);
    }
  }

  private void displayBottomSnackbar(View view, ReadableMap options, final Callback callback, String title, int duration){
    int layoutDirection = options.hasKey("direction") ? options.getInt("direction") : ViewCompat.LAYOUT_DIRECTION_LTR;
    int textDirection = options.hasKey("direction") ? options.getInt("direction") == ViewCompat.LAYOUT_DIRECTION_LTR ? Gravity.LEFT : Gravity.RIGHT : Gravity.START;

    Snackbar snackbar = Snackbar.make(view, title, duration);
    bottomActiveSnackbars.add(snackbar);

    TextView snackbarText = snackbar.getView().findViewById(android.support.design.R.id.snackbar_text);
    TextView action = snackbar.getView().findViewById(android.support.design.R.id.snackbar_action);


    // Set the background color.
    if (options.hasKey("backgroundColor")) {
      snackbar.getView().setBackgroundColor(options.getInt("backgroundColor"));
    }

    if (options.hasKey("action")) {
      View.OnClickListener onClickListener = new View.OnClickListener() {
        // Prevent double-taps which can lead to a crash.
        boolean callbackWasCalled = false;

        @Override
        public void onClick(View v) {
          if (callbackWasCalled) return;
          callbackWasCalled = true;

          callback.invoke();
        }
      };

      ReadableMap actionDetails = options.getMap("action");
      snackbar.setAction(actionDetails.getString("title"), onClickListener);
      snackbar.setActionTextColor(actionDetails.getInt("color"));
    }

    // For older devices, explicitly set the text color; otherwise it may appear dark gray.
    // http://stackoverflow.com/a/31084530/763231
    if(options.hasKey("color")){
      snackbarText.setTextColor(options.getInt("color"));

    }else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      snackbarText.setTextColor(Color.WHITE);
    }


    if(options.hasKey("fontFamily")){
      Typeface typeface = ReactFontManager.getInstance().getTypeface(
              options.getString("fontFamily"),
              Typeface.NORMAL,
              view.getContext().getAssets());

      snackbarText.setTypeface(typeface);
      action.setTypeface(typeface);
    }

    if(options.hasKey("fontSize")){
      int fontSize = options.getInt("fontSize");
      snackbarText.setTextSize(TypedValue.COMPLEX_UNIT_DIP, fontSize);
      action.setTextSize(TypedValue.COMPLEX_UNIT_DIP, fontSize);
    }

//    Typeface font = Typeface.createFromAsset(getReactApplicationContext().getAssets(), FONT_PATH);

    snackbarText.setGravity(textDirection);

    ViewCompat.setLayoutDirection(snackbar.getView(), layoutDirection);
    ViewCompat.setLayoutDirection(snackbarText, layoutDirection);


//    View snackbarView = snackbar.getView();
//    FrameLayout.LayoutParams params =(FrameLayout.LayoutParams)snackbarView.getLayoutParams();
//    params.gravity = Gravity.TOP;
//    snackbarView.setLayoutParams(params);

    snackbar.show();
  }


  private void displayTopSnackbar(View view, ReadableMap options, final Callback callback, String title, int duration){
    int layoutDirection = options.hasKey("direction") ? options.getInt("direction") : ViewCompat.LAYOUT_DIRECTION_LTR;
    int textDirection = options.hasKey("direction") ? options.getInt("direction") == ViewCompat.LAYOUT_DIRECTION_LTR ? Gravity.LEFT : Gravity.RIGHT : Gravity.START;

    TSnackbar snackbar = TSnackbar.make(view, title, duration);
    topActiveSnackbars.add(snackbar);

    TextView snackbarText = snackbar.getView().findViewById(R.id.snackbar_text);
    TextView action = snackbar.getView().findViewById(R.id.snackbar_action);


    // Set the background color.
    if (options.hasKey("backgroundColor")) {
      snackbar.getView().setBackgroundColor(options.getInt("backgroundColor"));
    }

    if (options.hasKey("action")) {
      View.OnClickListener onClickListener = new View.OnClickListener() {
        // Prevent double-taps which can lead to a crash.
        boolean callbackWasCalled = false;

        @Override
        public void onClick(View v) {
          if (callbackWasCalled) return;
          callbackWasCalled = true;

          callback.invoke();
        }
      };

      ReadableMap actionDetails = options.getMap("action");
      snackbar.setAction(actionDetails.getString("title"), onClickListener);
      if(actionDetails.hasKey("color")){
        snackbar.setActionTextColor(actionDetails.getInt("color"));
      }
    }

    // For older devices, explicitly set the text color; otherwise it may appear dark gray.
    // http://stackoverflow.com/a/31084530/763231
    if(options.hasKey("color")){
      snackbarText.setTextColor(options.getInt("color"));

    }else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      snackbarText.setTextColor(Color.WHITE);
    }


    if(options.hasKey("fontFamily")){
      Typeface typeface = ReactFontManager.getInstance().getTypeface(
              options.getString("fontFamily"),
              Typeface.NORMAL,
              view.getContext().getAssets());

      snackbarText.setTypeface(typeface);
      action.setTypeface(typeface);
    }

    if(options.hasKey("fontSize")){
      int fontSize = options.getInt("fontSize");
      snackbarText.setTextSize(TypedValue.COMPLEX_UNIT_DIP, fontSize);
      action.setTextSize(TypedValue.COMPLEX_UNIT_DIP, fontSize);
    }

//    Typeface font = Typeface.createFromAsset(getReactApplicationContext().getAssets(), FONT_PATH);

    snackbarText.setGravity(textDirection);

    ViewCompat.setLayoutDirection(snackbar.getView(), layoutDirection);
    ViewCompat.setLayoutDirection(snackbarText, layoutDirection);


//    View snackbarView = snackbar.getView();
//    FrameLayout.LayoutParams params =(FrameLayout.LayoutParams)snackbarView.getLayoutParams();
//    params.gravity = Gravity.TOP;
//    snackbarView.setLayoutParams(params);

    snackbar.show();
  }

  private void initStyle(View parent, TextView text, TextView action){

  }

  /**
   * Loop through all child modals and save references to them.
   */
  private ArrayList<View> recursiveLoopChildren(ViewGroup view, ArrayList<View> modals) {
    if (view.getClass().getSimpleName().equalsIgnoreCase("ReactModalHostView")) {
      modals.add(view.getChildAt(0));
    }

    for (int i = view.getChildCount() - 1; i >= 0; i--) {
      final View child = view.getChildAt(i);

      if (child instanceof ViewGroup) {
        recursiveLoopChildren((ViewGroup) child, modals);
      }
    }

    return modals;
  }

}
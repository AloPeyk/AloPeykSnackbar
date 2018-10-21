
package com.alopeyk.nativemodule.snackbar;

import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Build;
import android.support.design.widget.Snackbar;
import android.support.v4.view.ViewCompat;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RNSnackbarModule extends ReactContextBaseJavaModule {
  private static final String REACT_NAME = "Snackbar";
  private static final String FONT_PATH = "fonts/IRANSans.ttf";

  private List<Snackbar> mActiveSnackbars = new ArrayList<>();

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

    mActiveSnackbars.clear();

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
    for (Snackbar snackbar : mActiveSnackbars) {
      if (snackbar != null) {
        snackbar.dismiss();
      }
    }

    mActiveSnackbars.clear();
  }

  private void displaySnackbar(View view, ReadableMap options, final Callback callback) {
    String title = options.hasKey("title") ? options.getString("title") : "";
    int duration = options.hasKey("duration") ? options.getInt("duration") : Snackbar.LENGTH_SHORT;
    int layoutDirection = options.hasKey("direction") ? options.getInt("direction") : ViewCompat.LAYOUT_DIRECTION_LTR;
    int textDirection = options.hasKey("direction") ? options.getInt("direction") == ViewCompat.LAYOUT_DIRECTION_LTR ? Gravity.LEFT : Gravity.RIGHT : Gravity.START;

    Snackbar snackbar = Snackbar.make(view, title, duration);
    mActiveSnackbars.add(snackbar);

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

    
    Typeface font = Typeface.createFromAsset(getReactApplicationContext().getAssets(), FONT_PATH);
    snackbarText.setTypeface(font);
    action.setTypeface(font);

//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
//      snackbar.getView().setLayoutDirection(layoutDirection);
//    }
    snackbarText.setGravity(textDirection);

    ViewCompat.setLayoutDirection(snackbar.getView(), layoutDirection);
    ViewCompat.setLayoutDirection(snackbarText, layoutDirection);

    snackbar.show();
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
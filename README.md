
# alopeyk-snackbar
Snackbar plugin for react-native. 

![Alt Text](https://i.imgur.com/HSNH5Sh.gif)

## Features
- Supports RTL/LTR directions
- Customizable theme

## Installation

`$ npm install alopeyk-snackbar --save`

and then :

`$ react-native link alopeyk-snackbar`

#### Extra step for ios
Since this repo is written in swift, you should copy `Test.swift` from `node_modulles/alopeyk-snackbar/ios` to your project's XCode project navigator ➜ `[your project's name]` and then click on `copy items if needed` and press finish and then on the prompt select add bridge.

### Manual installation


#### iOS

1. This repo is written in swift and for linking swift code to your project you have to copy `Test.swift` from `node_modules/alopeyk-snackbar/ios` into your project's XCode project navigator `[your project's name]`
2. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
3. Go to `node_modules` ➜ `alopeyk-snackbar` and add `RNSnackbar.xcodeproj`
4. In XCode, in the project navigator, select your project. Add `libRNSnackbar.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
5. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.alopeyk.nativemodule.RNSnackbarPackage;` to the imports at the top of the file
  - Add `new RNSnackbarPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':alopeyk-snackbar'
  	project(':alopeyk-snackbar').projectDir = new File(rootProject.projectDir, 	'../node_modules/alopeyk-snackbar/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':alopeyk-snackbar')
  	```

## Usage
```javascript
import Snackbar from 'alopeyk-snackbar';

Snackbar.show({
	title: 'Please agree to this.',
	duration: Snackbar.LENGTH_INDEFINITE,
	backgroundColor: 'silver',
	color: '#333',
	maxLines: 3, //Default: 2
	barPosition: Snackbar.BAR_POSITION_TOP, //Default: Snackbar.BAR_POSITION_BOTTOM
	direction: Snackbar.DIRECTION_RTL, //Default: Snackbar.DIRECTION_LTR
	action: {
		title: 'AGREE',
		onPress: () => Snackbar.show({ title: 'Thank you!' }),
		color: '#992222',
	},
});

// dismiss snackbar
Snackbar.dismiss();
```
  
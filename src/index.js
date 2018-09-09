// @flow

import { NativeModules, processColor } from 'react-native';

type Action = {
  title: string,
  color?: string | number,
  onPress?: () => void,
};

type SnackBarOptions = {
  title: string,
  duration?: number,
  direction?: number,
  color?: string | number,
  backgroundColor?: string,
  action?: Action,
};

type ISnackBar = {
  LENGTH_LONG: number,
  LENGTH_SHORT: number,
  LENGTH_INDEFINITE: number,
  DIRECTION_LTR: number,
  DIRECTION_RTL: number,
  show: (options: SnackBarOptions) => void,
  dismiss: () => void,
};

const SnackBar: ISnackBar = {

  LENGTH_LONG: NativeModules.Snackbar.LENGTH_LONG,
  LENGTH_SHORT: NativeModules.Snackbar.LENGTH_SHORT,
  LENGTH_INDEFINITE: NativeModules.Snackbar.LENGTH_INDEFINITE,
  DIRECTION_LTR: NativeModules.Snackbar.DIRECTION_LTR,
  DIRECTION_RTL: NativeModules.Snackbar.DIRECTION_RTL,

  show(options: SnackBarOptions) {
    const onPressCallback = (options.action && options.action.onPress) || (() => {});

    if (options.action && options.action.color) {
      /* eslint-disable no-param-reassign */
      // $FlowFixMe
      options.action.color = processColor(options.action.color);
      /* eslint-enable */
    }

    if (options.color) {
      // eslint-disable-next-line no-param-reassign
      options.color = processColor(options.color);
    }

    if (options.backgroundColor) {
      // eslint-disable-next-line no-param-reassign
      options.backgroundColor = processColor(options.backgroundColor);
    }

    NativeModules.Snackbar.show(options, onPressCallback);
  },

  dismiss() {
    NativeModules.Snackbar.dismiss();
  },

};

export default SnackBar;

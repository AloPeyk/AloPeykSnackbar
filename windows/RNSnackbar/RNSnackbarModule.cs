using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Snackbar.RNSnackbar
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNSnackbarModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNSnackbarModule"/>.
        /// </summary>
        internal RNSnackbarModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNSnackbar";
            }
        }
    }
}

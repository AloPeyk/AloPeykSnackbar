import React, { Component } from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import Snackbar from 'alopeyk-snackbar';

import styles from './styles';

// eslint-disable-next-line react/prefer-stateless-function
class Example extends Component {
  constructor(){
    super();
    this.state = {
      barPosition: Snackbar.BAR_POSITION_BOTTOM,
      barPosiotionTitle: "Position: Bottom",
    }
  }

  toggleBarPosition(){
    if(this.state.barPosition == Snackbar.BAR_POSITION_TOP){
      this.setState({barPosition: Snackbar.BAR_POSITION_BOTTOM, barPosiotionTitle: "Position: Bottom",});
    }else{
      this.setState({barPosition: Snackbar.BAR_POSITION_TOP, barPosiotionTitle: "Position: Top",});
    }
  }

  render() {
    
    return (
      <View style={styles.container}>
        <Text style={styles.title}>
          Snackbar Examples
        </Text>
        <View>
          <TouchableOpacity
            onPress={this.toggleBarPosition.bind(this)}
          >
            <Text style={styles.position}>{this.state.barPosiotionTitle}</Text>
          </TouchableOpacity>
        </View>

        <TouchableOpacity
          onPress={() => Snackbar.show({ 
            title: 'Hello, World!', 
            barPosition: this.state.barPosition,
            })}
        >
          <Text style={styles.button}>
            Simple Snackbar
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            title: 'Hello, World! How are you doing today? Enjoying the sun?! This should wrap to two lines.',
            duration: Snackbar.LENGTH_LONG,
            barPosition: this.state.barPosition,
          })}
        >
          <Text style={styles.button}>
            Simple Snackbar - two lines
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            title: 'Please agree to this.',
            duration: Snackbar.LENGTH_INDEFINITE,
            barPosition: this.state.barPosition,
            fontFamily: 'Roboto-Light',
            fontSize: 14,
            action: {
              title: 'AGREE',
              onPress: () => Snackbar.show({ 
                title: 'Thank you!', 
                barPosition: this.state.barPosition,
                }),
              color: 'green',
            },
          })}
        >
          <Text style={styles.button}>
            Snackbar with action
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.show({
            title: 'Please agree to this.',
            duration: Snackbar.LENGTH_INDEFINITE,
            barPosition: this.state.barPosition,
            backgroundColor: 'silver',
            color: '#333',
            action: {
              title: 'AGREE',
              onPress: () => Snackbar.show({ 
                title: 'Thank you!',
                barPosition: this.state.barPosition,
                }),
              color: '#992222',
            },
          })}
        >
          <Text style={styles.button}>
            Snackbar with style
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => Snackbar.dismiss()}
        >
          <Text style={styles.buttonDismiss}>
            Dismiss active Snackbar
          </Text>
        </TouchableOpacity>
      </View>
    );
  }

}

export default Example;
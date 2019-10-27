import React from 'react';
import { SafeAreaView } from 'react-native'
export const safeRender = (children) => (
    <SafeAreaView style={{flex: 1}}>{children}</SafeAreaView>
);

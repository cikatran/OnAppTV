import Home from "../Home";
import MyCategories from "../MyCategories";
import {StackNavigator} from "react-navigation";
import Category from "../Category";
import defaultNavigationOptions from "../../utils/navigationOption";

export default HomeStack = StackNavigator({
    Home: {
        screen: Home,
        navigationOptions: ({navigation}) => ({
            header: null,
            gesturesEnabled: false,
        }),
    },
    MyCategories: {
        screen: MyCategories,
        navigationOptions: ({navigation}) => ({
            ...defaultNavigationOptions("My Categories", navigation, true)
        })
    },
    Category: {
        screen: Category,
        navigationOptions: ({navigation}) => ({
            header: null,
            gesturesEnabled: false
        })
    }
});
import {PixelRatio} from 'react-native'

export function getImageFromArray(images, firstImageName, secondImageName) {
    if (images == null || images.length == 0) {
        return 'https://i.imgur.com/7eKo6Q7.png'
    }
    let image = null;
    images.forEach((item)=> {
        if (item.name === firstImageName) {
            let scaledImages = item.scaledImage
            if (scaledImages != null) {
                if (firstImageName === 'feature' && scaledImages.length > 2) {
                    image = scaledImages[1].url;
                } else {
                    image = scaledImages[scaledImages.length - 2].url;
                }
            }
        }
        // if (image == null && item.name === secondImageName) {
        //     let scaledImages = item.scaledImage
        //     if (scaledImages != null) {
        //         if (secondImageName === 'feature' && scaledImages.length > 2) {
        //             image = scaledImages[1].url;
        //         } else {
        //             image = scaledImages[scaledImages.length - 1].url;
        //         }
        //
        //     }
        // }
    });
    if (image == null) {
        return 'https://i.imgur.com/7eKo6Q7.png'
    }
    //image = (image == null) ? images[0].url : image;
    return image;
}

export const IMAGE_TYPE = {
    LOGO: "Logo",
    PORTRAIT: "P",
    LANDSCAPE: "L"
}

export const IMAGE_SIZE = {
    SMALL: "S",
    MEDIUM: "M",
    LARGE: "L"
}

export function getOnAppTVImage(thumbnail, type, size) {
    let sizeScale = '1x';
    if (PixelRatio.get() < 2) {
        sizeScale = '1x'
    } else if(PixelRatio.get() < 3) {
        sizeScale = '2x'
    } else {
        sizeScale = '3x'
    }
    if (thumbnail) {
        if (thumbnail[`${type}_${size}_${sizeScale}`])
            return thumbnail[`${type}_${size}_${sizeScale}`][`url`];
    }
    return "";
}
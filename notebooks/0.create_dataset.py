"""
Dataset preparation script.

This script creates TFRecord files from the original image dataset while keeping
the annotation files synchronized with the generated samples.

Processing pipeline
-------------------
1. Read the original images from the male and female folders.
2. Apply a common preprocessing pipeline (center crop + grayscale conversion).
3. Optionally generate augmented samples.
4. Store all samples into TFRecord files.
5. Duplicate the corresponding labels for the augmented images.

Inputs
------
- Image directory containing the folders:
    - male/
    - female/
- Original annotation CSV files.

Outputs
-------
- One TFRecord file per gender.
- One updated annotation CSV per gender including the labels of the
  augmented samples.
"""

import argparse
import os

import pandas as pd
import tensorflow as tf
from tqdm import tqdm


def parse_args():
    """Read command-line arguments."""

    parser = argparse.ArgumentParser(
        description="Create TFRecords and synchronized annotation files."
    )

    parser.add_argument("--images-dir", required=True,
                        help="Directory containing the male and female image folders.")
    parser.add_argument("--male-csv", required=True,
                        help="Original male annotation CSV.")
    parser.add_argument("--female-csv", required=True,
                        help="Original female annotation CSV.")
    parser.add_argument("--male-output", default="male.tfrecord")
    parser.add_argument("--female-output", default="female.tfrecord")
    parser.add_argument("--male-output-csv", required=True)
    parser.add_argument("--female-output-csv", required=True)
    parser.add_argument("--augment-limit", type=int, default=25000,
                        help="Number of images to augment.")
    parser.add_argument("--crop-size", type=int, default=257,
                        help="Width of the central crop.")

    return parser.parse_args()


def _bytes_feature(value):
    """Serialize a byte string into a TFRecord feature."""
    return tf.train.Feature(bytes_list=tf.train.BytesList(value=[value]))


def apply_center_crop(image, crop_size):
    """Crop the image horizontally around its center."""

    # Images already share the same height, therefore only the width
    # is cropped to better center the subject.
    height = tf.shape(image)[0]
    width = tf.shape(image)[1]

    target_width = tf.minimum(crop_size, width)
    offset_width = tf.maximum((width - target_width) // 2, 0)

    return tf.image.crop_to_bounding_box(
        image,
        offset_height=0,
        offset_width=offset_width,
        target_height=height,
        target_width=target_width,
    )


def force_grayscale(image):
    """Convert an RGB image to grayscale while preserving three channels."""

    # Most pretrained CNNs expect three input channels.
    image = tf.image.rgb_to_grayscale(image)
    return tf.image.grayscale_to_rgb(image)


def process_image(image_bytes, crop_size, augment=False):
    """Apply preprocessing and optional augmentation."""

    image = tf.io.decode_image(
        image_bytes,
        channels=3,
        expand_animations=False,
    )

    image = tf.cast(image, tf.float32)

    # Every image follows the same preprocessing pipeline.
    image = apply_center_crop(image, crop_size)
    image = force_grayscale(image)

    if augment:
        # Augmentations are intentionally mild so that body proportions
        # remain unchanged while increasing visual variability.
        image = tf.image.random_flip_left_right(image)
        image = tf.image.random_brightness(image, max_delta=0.2)
        image = tf.image.random_contrast(image, lower=0.7, upper=1.3)

        # Downsampling and upsampling approximates a slight blur.
        if tf.random.uniform([]) < 0.5:
            shape = tf.shape(image)
            image = tf.image.resize(image, [shape[0] // 2, shape[1] // 2])
            image = tf.image.resize(image, [shape[0], shape[1]])

        noise = tf.random.normal(
            tf.shape(image),
            mean=0.0,
            stddev=5.0,
        )
        image += noise

    image = tf.cast(tf.clip_by_value(image, 0.0, 255.0), tf.uint8)

    return tf.io.encode_jpeg(image).numpy()


def create_augmented_csv(input_csv, output_csv, augment_limit):
    """Duplicate labels for augmented samples."""

    # Geometric and photometric transformations do not modify the
    # anthropometric measurements, so labels can be reused.
    df = pd.read_csv(input_csv, header=None)
    augmented = df.head(augment_limit).copy()

    pd.concat([df, augmented], ignore_index=True).to_csv(
        output_csv,
        index=False,
        header=False,
    )


def create_example(image_bytes):
    """Build a serialized TFRecord example."""

    example = tf.train.Example(
        features=tf.train.Features(
            feature={"image": _bytes_feature(image_bytes)}
        )
    )

    return example.SerializeToString()


def write_tfrecord(image_dir, output_path, crop_size, augment_limit):
    """Create a TFRecord file from a directory of images."""

    image_paths = sorted(
        os.path.join(image_dir, f)
        for f in os.listdir(image_dir)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    )

    print(f"Found {len(image_paths)} images in '{image_dir}'.")

    with tf.io.TFRecordWriter(output_path) as writer:

        # Store every original sample.
        for image_path in tqdm(image_paths, desc="Original images"):
            with open(image_path, "rb") as f:
                writer.write(
                    create_example(
                        process_image(f.read(), crop_size)
                    )
                )

        # Append augmented samples to the same TFRecord.
        for image_path in tqdm(image_paths[:augment_limit],
                               desc="Augmented images"):
            with open(image_path, "rb") as f:
                writer.write(
                    create_example(
                        process_image(
                            f.read(),
                            crop_size,
                            augment=True,
                        )
                    )
                )

    print(f"Saved TFRecord to '{output_path}'.")


def main():
    args = parse_args()

    male_dir = os.path.join(args.images_dir, "male")
    female_dir = os.path.join(args.images_dir, "female")

    print("\n[Step 1/4] Creating male TFRecord...")
    write_tfrecord(
        male_dir,
        args.male_output,
        args.crop_size,
        args.augment_limit,
    )

    print("\n[Step 2/4] Creating female TFRecord...")
    write_tfrecord(
        female_dir,
        args.female_output,
        args.crop_size,
        args.augment_limit,
    )

    print("\n[Step 3/4] Updating annotation files...")
    create_augmented_csv(
        args.male_csv,
        args.male_output_csv,
        args.augment_limit,
    )

    create_augmented_csv(
        args.female_csv,
        args.female_output_csv,
        args.augment_limit,
    )

    print("\n[Step 4/4] Dataset generation completed successfully.")


if __name__ == "__main__":
    main()

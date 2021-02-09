# Object Identification as a shopping aid for Visually Impaired

 ##### Dataset:

   - We have used Freiburg groceries dataset to build our model.

   - The dataset consists of 4947 images with 25 classes of groceries.

   - Each class consists of 97-430 images on average.

   - The paper can be found [here](https://arxiv.org/pdf/1611.05799.pdf) and the dataset [here](http://aisdatasets.informatik.uni-freiburg.de/freiburg_groceries_dataset/)

   ###### Environment and Tools used for Model:

    - Jupyter Notebook
    - Flask
    - Tensorflow
    - Flutter

   ###### Model:
 
    We have used VGG16 architecture and transfer learning to build the model which shows effective 
    result in multi-class image classification. The model is converted to H5 type while training which is 
    then converted to an API using Flask. That API is used in the application development process




from setuptools import setup, find_packages

setup(
    name='mrtrix_pipeline',
    version='1.0.0',
    description='MRtrix3 弥散 MRI 处理管线终端工具',
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        'click>=8.0',
        'numpy>=1.20',
    ],
    entry_points={
        'console_scripts': [
            'mrtrix-cli=mrtrix_pipeline.cli:cli',
        ],
    },
    python_requires='>=3.7',
)
